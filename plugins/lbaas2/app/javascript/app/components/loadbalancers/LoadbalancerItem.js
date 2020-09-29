import { useEffect, useMemo } from "react"
import { Link } from "react-router-dom"
import CachedInforPopover from "../shared/CachedInforPopover"
import CachedInfoPopoverListenerContent from "./CachedInfoPopoverListenerContent"
import CachedInfoPopoverPoolContent from "./CachedInfoPopoverPoolContent"
import StaticTags from "../StaticTags"
import StateLabel from "../shared/StateLabel"
import StatusLabel from "../shared/StatusLabel"
import useLoadbalancer from "../../../lib/hooks/useLoadbalancer"
import CopyPastePopover from "../shared/CopyPastePopover"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"
import SmartLink from "../shared/SmartLink"
import { policy } from "policy"
import { scope } from "ajax_helper"
import useCommons from "../../../lib/hooks/useCommons"
import Log from "../shared/logger"

const LoadbalancerItem = ({
  loadbalancer,
  searchTerm,
  disabled,
  shouldPoll,
}) => {
  const {
    persistLoadbalancer,
    deleteLoadbalancer,
    detachFIP,
  } = useLoadbalancer()
  const { errorMessage } = useCommons()
  let polling = null

  useEffect(() => {
    if (shouldPoll) {
      if (loadbalancer.provisioning_status.includes("PENDING")) {
        startPolling(5000)
      } else {
        startPolling(30000)
      }
    }
    return function cleanup() {
      if (shouldPoll) stopPolling()
    }
  })

  const startPolling = (interval) => {
    // do not create a new polling interval if already polling
    if (polling) return
    Log.debug(
      "Polling loadbalancer -->",
      loadbalancer.id,
      " with interval -->",
      interval
    )
    polling = setInterval(() => {
      persistLoadbalancer(loadbalancer.id).catch((error) => {})
    }, interval)
  }

  const stopPolling = () => {
    Log.debug("stop polling for id -->", loadbalancer.id)
    clearInterval(polling)
    polling = null
  }

  const canDelete = useMemo(
    () =>
      policy.isAllowed("lbaas2:loadbalancer_delete", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const canEdit = useMemo(
    () =>
      policy.isAllowed("lbaas2:loadbalancer_update", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const canAttachFIP = useMemo(
    () =>
      policy.isAllowed("lbaas2:loadbalancer_attach_fip", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const canDetachFIP = useMemo(
    () =>
      policy.isAllowed("lbaas2:loadbalancer_detach_fip", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    const ladbalancerID = loadbalancer.id
    const loadbalancerName = loadbalancer.name
    return deleteLoadbalancer(loadbalancerName, ladbalancerID)
      .then((response) => {
        addNotice(
          <React.Fragment>
            Load Balancer <b>{loadbalancerName}</b> ({ladbalancerID}) is being
            deleted.
          </React.Fragment>
        )
      })
      .catch((error) => {
        addError(
          React.createElement(ErrorsList, {
            errors: errorMessage(error.response),
          })
        )
      })
  }

  const handleDetachFIP = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }

    const ladbalancerID = loadbalancer.id
    const floatingIP = loadbalancer.floating_ip.id
    return detachFIP(ladbalancerID, { floating_ip: floatingIP })
      .then((response) => {
        addNotice(
          <React.Fragment>
            Floating IP <b>{loadbalancer.floating_ip.floating_ip_address}</b> (
            {floatingIP}) is being detached.
          </React.Fragment>
        )
      })
      .catch((error) => {
        addError(
          React.createElement(ErrorsList, {
            errors: errorMessage(error),
          })
        )
      })
  }

  const poolIds = loadbalancer.pools.map((p) => p.id)
  const listenerIds = loadbalancer.listeners.map((l) => l.id)
  const displayName = () => {
    const name = loadbalancer.name || loadbalancer.id
    if (disabled) {
      return (
        <span className="info-text">
          <CopyPastePopover
            text={name}
            size={40}
            sliceType="MIDDLE"
            shouldCopy={false}
            bsClass="cp copy-paste-ids"
          />
        </span>
      )
    } else {
      return (
        <Link to={`/loadbalancers/${loadbalancer.id}/show`}>
          <CopyPastePopover
            text={name}
            size={40}
            sliceType="MIDDLE"
            shouldPopover={false}
            shouldCopy={false}
            searchTerm={searchTerm}
          />
        </Link>
      )
    }
  }
  const displayID = () => {
    if (loadbalancer.name) {
      if (disabled) {
        return (
          <div className="info-text">
            <CopyPastePopover
              text={loadbalancer.id}
              size={40}
              sliceType="MIDDLE"
              bsClass="cp copy-paste-ids"
            />
          </div>
        )
      } else {
        return (
          <CopyPastePopover
            text={loadbalancer.id}
            size={40}
            sliceType="MIDDLE"
            bsClass="cp copy-paste-ids"
            searchTerm={searchTerm}
          />
        )
      }
    }
  }

  Log.debug("RENDER loadbalancer list item id-->", loadbalancer.id)
  return (
    <tr className={disabled ? "active" : ""}>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
        <CopyPastePopover
          text={loadbalancer.description}
          size={40}
          shouldCopy={false}
          shouldPopover={true}
          searchTerm={searchTerm}
        />
      </td>
      <td>
        <StateLabel label={loadbalancer.operating_status} />
      </td>
      <td>
        <StatusLabel label={loadbalancer.provisioning_status} />
      </td>
      <td>
        <StaticTags tags={loadbalancer.tags} />
      </td>
      <td className="snug-nowrap">
        {loadbalancer.subnet && (
          <React.Fragment>
            <p
              className="list-group-item-text list-group-item-text-copy"
              data-is-from-cache={loadbalancer.subnet_from_cache}
            >
              {loadbalancer.subnet.name}
            </p>
          </React.Fragment>
        )}
        {loadbalancer.vip_address && (
          <React.Fragment>
            <p className="list-group-item-text list-group-item-text-copy display-flex">
              <i className="fa fa-desktop fa-fw" />
              <CopyPastePopover
                text={loadbalancer.vip_address}
                size={20}
                searchTerm={searchTerm}
              />
            </p>
          </React.Fragment>
        )}
        {loadbalancer.floating_ip && (
          <React.Fragment>
            <p className="list-group-item-text list-group-item-text-copy display-flex">
              <i className="fa fa-globe fa-fw" />
              <CopyPastePopover
                text={loadbalancer.floating_ip.floating_ip_address}
                size={20}
                searchTerm={searchTerm}
              />
            </p>
          </React.Fragment>
        )}
      </td>
      <td>
        {disabled ? (
          <span className="info-text">{listenerIds.length}</span>
        ) : (
          <CachedInforPopover
            popoverId={"listener-popover-" + loadbalancer.id}
            buttonName={listenerIds.length}
            title={
              <React.Fragment>
                Listeners
                <Link
                  to={`/loadbalancers/${loadbalancer.id}/show`}
                  style={{ float: "right" }}
                >
                  Show all
                </Link>
              </React.Fragment>
            }
            content={
              <CachedInfoPopoverListenerContent
                lbID={loadbalancer.id}
                listenerIds={listenerIds}
                cachedListeners={loadbalancer.cached_listeners}
              />
            }
          />
        )}
      </td>
      <td>
        {disabled ? (
          <span className="info-text">{poolIds.length}</span>
        ) : (
          <CachedInforPopover
            popoverId={"pools-popover-" + loadbalancer.id}
            buttonName={poolIds.length}
            title={
              <React.Fragment>
                Pools
                <Link
                  to={`/loadbalancers/${loadbalancer.id}/show`}
                  style={{ float: "right" }}
                >
                  Show all
                </Link>
              </React.Fragment>
            }
            content={
              <CachedInfoPopoverPoolContent
                lbID={loadbalancer.id}
                poolIds={poolIds}
                cachedPools={loadbalancer.cached_pools}
              />
            }
          />
        )}
      </td>
      <td>
        <div className="btn-group">
          <button
            className="btn btn-default btn-sm dropdown-toggle"
            type="button"
            data-toggle="dropdown"
            aria-expanded={true}
          >
            <span className="fa fa-cog"></span>
          </button>
          <ul className="dropdown-menu dropdown-menu-right" role="menu">
            <li>
              <SmartLink
                to={
                  disabled
                    ? `/loadbalancers/${loadbalancer.id}/show/edit`
                    : `/loadbalancers/${loadbalancer.id}/edit`
                }
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
            <li className="divider"></li>
            <li>
              {loadbalancer.floating_ip ? (
                <SmartLink
                  onClick={handleDetachFIP}
                  isAllowed={canDetachFIP}
                  notAllowedText="Not allowed to detach Floating IP. Please check with your administrator."
                >
                  Detach Floating IP
                </SmartLink>
              ) : (
                <SmartLink
                  to={`/loadbalancers/${loadbalancer.id}/attach_fip`}
                  isAllowed={canAttachFIP}
                  notAllowedText="Not allowed to attach Floating IP. Please check with your administrator."
                >
                  Attach Floating IP
                </SmartLink>
              )}
            </li>
          </ul>
        </div>
      </td>
    </tr>
  )
}

LoadbalancerItem.displayName = "LoadbalancerItem"

export default LoadbalancerItem
