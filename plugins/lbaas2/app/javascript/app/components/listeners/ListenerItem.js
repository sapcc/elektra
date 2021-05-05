import { useEffect, useState, useMemo } from "react";
import { Link } from "react-router-dom";
import StaticTags from "../StaticTags";
import { Tooltip, OverlayTrigger } from "react-bootstrap";
import CopyPastePopover from "../shared/CopyPastePopover";
import CachedInfoPopover from "../shared/CachedInforPopover";
import CachedInfoPopoverContent from "./CachedInfoPopoverContent";
import CachedInfoPopoverContentContainers from "../shared/CachedInfoPopoverContentContainers";
import useListener from "../../../lib/hooks/useListener";
import useCommons from "../../../lib/hooks/useCommons";
import useLoadbalancer from "../../../lib/hooks/useLoadbalancer";
import { addNotice, addError } from "lib/flashes";
import { ErrorsList } from "lib/elektra-form/components/errors_list";
import { policy } from "policy";
import { scope } from "ajax_helper";
import SmartLink from "../shared/SmartLink";
import Log from "../shared/logger";
import DropDownMenu from "../shared/DropdownMenu";
import useStatus from "../../../lib/hooks/useStatus";

const ListenerItem = ({ props, listener, searchTerm, disabled }) => {
  const {
    persistListener,
    certificateContainerRelation,
    deleteListener,
    onSelectListener,
    reset,
  } = useListener();
  const {
    MyHighlighter,
    matchParams,
    errorMessage,
    searchParamsToString,
  } = useCommons();
  const { persistLoadbalancer } = useLoadbalancer();
  let polling = null;
  const [loadbalancerID, setLoadbalancerID] = useState(null);
  const { entityStatus } = useStatus(
    listener.operating_status,
    listener.provisioning_status
  );

  useEffect(() => {
    const params = matchParams(props);
    setLoadbalancerID(params.loadbalancerID);

    if (listener.provisioning_status.includes("PENDING")) {
      startPolling(5000);
    } else {
      startPolling(30000);
    }

    return function cleanup() {
      stopPolling();
    };
  });

  const startPolling = (interval) => {
    // do not create a new polling interval if already polling
    if (polling) return;
    polling = setInterval(() => {
      Log.debug(
        "Polling listener -->",
        listener.id,
        " with interval -->",
        interval
      );
      persistListener(loadbalancerID, listener.id).catch((error) => {
        if (error && error.status == 404) {
          // check if listener selected and if yes deselect the item
          if (disabled) {
            reset();
          }
        }
      });
    }, interval);
  };

  const stopPolling = () => {
    Log.debug("stop polling for listener id -->", listener.id);
    clearInterval(polling);
    polling = null;
  };

  const onListenerClick = (e) => {
    if (e) {
      e.stopPropagation();
      e.preventDefault();
    }
    onSelectListener(props, listener.id);
  };

  const canEdit = useMemo(
    () =>
      policy.isAllowed("lbaas2:listener_update", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  );

  const canDelete = useMemo(
    () =>
      policy.isAllowed("lbaas2:listener_delete", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  );

  const canShowJSON = useMemo(
    () =>
      policy.isAllowed("lbaas2:listener_get", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  );

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation();
      e.preventDefault();
    }
    const listenerID = listener.id;
    const listenerName = listener.name;
    return deleteListener(loadbalancerID, listenerID, listenerName)
      .then((response) => {
        addNotice(
          <React.Fragment>
            Listener <b>{listenerName}</b> ({listenerID}) is being deleted.
          </React.Fragment>
        );
        // fetch the lb again containing the new listener so it gets updated fast
        persistLoadbalancer(loadbalancerID).catch((error) => {});
      })
      .catch((error) => {
        addError(
          React.createElement(ErrorsList, {
            errors: errorMessage(error.response),
          })
        );
      });
  };

  const displayName = () => {
    const name = listener.name || listener.id;
    if (disabled) {
      return (
        <div className="info-text">
          <CopyPastePopover
            text={name}
            size={20}
            sliceType="MIDDLE"
            shouldCopy={false}
            bsClass="cp copy-paste-ids"
          />
        </div>
      );
    } else {
      return (
        <Link to="#" onClick={onListenerClick}>
          <CopyPastePopover
            text={name}
            size={20}
            sliceType="MIDDLE"
            shouldPopover={false}
            shouldCopy={false}
            searchTerm={searchTerm}
          />
        </Link>
      );
    }
  };

  const displayID = () => {
    if (listener.name) {
      if (disabled) {
        return (
          <div className="info-text">
            <CopyPastePopover
              text={listener.id}
              size={12}
              sliceType="MIDDLE"
              bsClass="cp copy-paste-ids"
            />
          </div>
        );
      } else {
        return (
          <CopyPastePopover
            text={listener.id}
            size={12}
            sliceType="MIDDLE"
            bsClass="cp copy-paste-ids"
            searchTerm={searchTerm}
          />
        );
      }
    }
  };

  const collectContainers = () => {
    const containers = [
      {
        name: "Certificate Secret",
        ref: listener.default_tls_container_ref,
      },
      { name: "SNI Secrets", refList: listener.sni_container_refs },
      {
        name: "Client Authentication Secret",
        ref: listener.client_ca_tls_container_ref,
      },
    ];
    var filteredContainers = containers.reduce((filteredContainers, item) => {
      if (
        (item.ref && item.ref.length > 0) ||
        (item.refList && item.refList.length > 0)
      ) {
        filteredContainers.push(item);
      }
      return filteredContainers;
    }, []);
    return filteredContainers;
  };

  const displayProtocol = () => {
    const containers = collectContainers();
    const numberOfElements = containers.reduce(
      (numberOfElements, container) => {
        if (container.ref) {
          return numberOfElements + 1;
        } else if (container.refList) {
          return numberOfElements + container.refList.length;
        } else {
          return numberOfElements;
        }
      },
      0
    );

    return (
      <React.Fragment>
        <MyHighlighter search={searchTerm}>{listener.protocol}</MyHighlighter>
        {certificateContainerRelation(listener.protocol) && (
          <div className="display-flex">
            <span>Client Auth: </span>
            <span className="label-right">
              {listener.client_authentication}
            </span>
          </div>
        )}
        {certificateContainerRelation(listener.protocol) && (
          <div className="display-flex">
            <span>Secrets: </span>
            <div className="label-right">
              <CachedInfoPopover
                popoverId={"listeners-secrets-popover-" + listener.id}
                buttonName={numberOfElements}
                title={<React.Fragment>Secrets</React.Fragment>}
                content={
                  <CachedInfoPopoverContentContainers containers={containers} />
                }
              />
            </div>
          </div>
        )}
      </React.Fragment>
    );
  };

  const l7PolicyIDs = listener.l7policies.map((l7p) => l7p.id);
  return (
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
        <CopyPastePopover
          text={listener.description}
          size={20}
          shouldCopy={false}
          shouldPopover={true}
          searchTerm={searchTerm}
        />
      </td>
      <td>{entityStatus}</td>
      <td>
        <StaticTags tags={listener.tags} />
      </td>
      <td>{displayProtocol()}</td>
      <td>
        <MyHighlighter search={searchTerm}>
          {listener.protocol_port}
        </MyHighlighter>
      </td>
      <td>
        {listener.default_pool_id ? (
          <OverlayTrigger
            placement="top"
            overlay={
              <Tooltip id="defalult-pool-tooltip">
                {listener.default_pool_id}
              </Tooltip>
            }
          >
            <i className="fa fa-check" />
          </OverlayTrigger>
        ) : (
          <i className="fa fa-times" />
        )}
      </td>
      <td>{listener.connection_limit}</td>
      <td>
        <StaticTags tags={listener.insert_headers} />
      </td>
      <td>
        {disabled ? (
          <span className="info-text">{l7PolicyIDs.length}</span>
        ) : (
          <CachedInfoPopover
            popoverId={"l7policies-popover-" + listener.id}
            buttonName={l7PolicyIDs.length}
            title={
              <React.Fragment>
                L7 Policies
                <Link
                  to="#"
                  onClick={onListenerClick}
                  style={{ float: "right" }}
                >
                  Show all
                </Link>
              </React.Fragment>
            }
            content={
              <CachedInfoPopoverContent
                props={props}
                lbID={loadbalancerID}
                listenerID={listener.id}
                l7PolicyIDs={l7PolicyIDs}
                cachedl7PolicyIDs={listener.cached_l7policies}
              />
            }
          />
        )}
      </td>
      <td>
        <DropDownMenu buttonIcon={<span className="fa fa-cog" />}>
          <li>
            <SmartLink
              to={`/loadbalancers/${loadbalancerID}/listeners/${
                listener.id
              }/edit?${searchParamsToString(props)}`}
              isAllowed={canEdit}
              notAllowedText="Not allowed to edit. Please check with your administrator."
            >
              Edit
            </SmartLink>
          </li>
          <li>
            <SmartLink
              onClick={handleDelete}
              isAllowed={canDelete}
              notAllowedText="Not allowed to delete. Please check with your administrator."
            >
              Delete
            </SmartLink>
          </li>
          <li>
            <SmartLink
              to={`/loadbalancers/${loadbalancerID}/listeners/${
                listener.id
              }/json?${searchParamsToString(props)}`}
              isAllowed={canShowJSON}
              notAllowedText="Not allowed to get JSOn. Please check with your administrator."
            >
              JSON
            </SmartLink>
          </li>
        </DropDownMenu>
      </td>
    </tr>
  );
};

export default ListenerItem;
