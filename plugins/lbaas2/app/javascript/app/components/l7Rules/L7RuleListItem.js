import { useEffect, useState, useMemo } from "react";
import useCommons from "../../../lib/hooks/useCommons";
import CopyPastePopover from "../shared/CopyPastePopover";
import StaticTags from "../StaticTags";
import useL7Rule from "../../../lib/hooks/useL7Rule";
import SmartLink from "../shared/SmartLink";
import { policy } from "policy";
import { scope } from "ajax_helper";
import Log from "../shared/logger";
import DropDownMenu from "../shared/DropdownMenu";
import useStatus from "../../../lib/hooks/useStatus";

const L7RuleListItem = ({
  props,
  listenerID,
  l7PolicyID,
  l7Rule,
  searchTerm,
}) => {
  const { MyHighlighter, matchParams, errorMessage, searchParamsToString } =
    useCommons();
  const { deleteL7Rule, displayInvert, persistL7Rule } = useL7Rule();
  const [loadbalancerID, setLoadbalancerID] = useState(null);
  const { entityStatus } = useStatus(
    l7Rule.operating_status,
    l7Rule.provisioning_status
  );
  let polling = null;

  useEffect(() => {
    const params = matchParams(props);
    setLoadbalancerID(params.loadbalancerID);

    if (l7Rule.provisioning_status.includes("PENDING")) {
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
        "Polling l7 rule -->",
        l7Rule.id,
        " with interval -->",
        interval
      );
      persistL7Rule(loadbalancerID, listenerID, l7PolicyID, l7Rule.id).catch(
        (error) => {}
      );
    }, interval);
  };

  const stopPolling = () => {
    Log.debug("stop polling for l7rule id -->", l7Rule.id);
    clearInterval(polling);
    polling = null;
  };

  const canEdit = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7rule_update", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  );

  const canDelete = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7rule_delete", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  );

  const canShowJSON = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7rule_get", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  );

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation();
      e.preventDefault();
    }
    deleteL7Rule(loadbalancerID, listenerID, l7PolicyID, l7Rule).then(() => {});
  };

  return (
    <tr>
      <td className="snug-nowrap">
        <CopyPastePopover
          text={l7Rule.id}
          size={12}
          sliceType="MIDDLE"
          bsClass="cp copy-paste-ids"
          searchTerm={searchTerm}
        />
      </td>
      <td>{entityStatus}</td>
      <td>
        <StaticTags tags={l7Rule.tags} shouldPopover={true} />
      </td>
      <td className="word-break">
        <MyHighlighter search={searchTerm}>{l7Rule.type}</MyHighlighter>
        <br />
        {l7Rule.compare_type}
      </td>
      <td>{displayInvert(l7Rule.invert)}</td>
      <td>
        <CopyPastePopover text={l7Rule.key} size={12} />
      </td>
      <td>
        <CopyPastePopover
          text={l7Rule.value}
          size={12}
          searchTerm={searchTerm}
        />
      </td>
      <td>
        <DropDownMenu buttonIcon={<span className="fa fa-cog" />}>
          <li>
            <SmartLink
              to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${
                l7Rule.id
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
              to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${
                l7Rule.id
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

export default L7RuleListItem;
