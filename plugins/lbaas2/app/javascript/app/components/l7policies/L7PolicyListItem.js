import { useEffect, useState, useMemo } from "react"
import useCommons from "../../../lib/hooks/useCommons"
import { Link } from "react-router-dom"
import StaticTags from "../StaticTags"
import useL7Policy from "../../../lib/hooks/useL7Policy"
import CopyPastePopover from "../shared/CopyPastePopover"
import useListener from "../../../lib/hooks/useListener"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"
import CachedInfoPopover from "../shared/CachedInforPopover"
import CachedInfoPopoverContent from "./CachedInfoPopoverContent"
import { policy } from "policy"
import { scope } from "ajax_helper"
import SmartLink from "../shared/SmartLink"
import Log from "../shared/logger"
import DropDownMenu from "../shared/DropdownMenu"
import useStatus from "../../../lib/hooks/useStatus"
import usePolling from "../../../lib/hooks/usePolling"

const L7PolicyListItem = ({
  props,
  l7Policy,
  searchTerm,
  listenerID,
  disabled,
  shouldPoll,
}) => {
  const { MyHighlighter, matchParams, errorMessage, searchParamsToString } =
    useCommons()
  const {
    actionRedirect,
    deleteL7Policy,
    persistL7Policy,
    onSelectL7Policy,
    reset,
  } = useL7Policy()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const { persistListener } = useListener()
  const { entityStatus } = useStatus(
    l7Policy.operating_status,
    l7Policy.provisioning_status
  )

  useEffect(() => {
    const params = matchParams(props)
    setLoadbalancerID(params.loadbalancerID)
  }, [])

  const pollingCallback = () => {
    return persistL7Policy(loadbalancerID, listenerID, l7Policy.id)
  }

  usePolling({
    delay: l7Policy.provisioning_status.includes("PENDING") ? 20000 : 60000,
    callback: pollingCallback,
    active: shouldPoll || l7Policy?.provisioning_status?.includes("PENDING"),
  })

  const onL7PolicyClick = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectL7Policy(props, l7Policy.id)
  }

  const canEdit = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7policy_update", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const canDelete = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7policy_delete", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const canShowJSON = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7policy_get", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const handleDelete = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    const l7policyID = l7Policy.id
    const l7policyName = l7Policy.name
    return deleteL7Policy(loadbalancerID, listenerID, l7policyID, l7policyName)
      .then((response) => {
        addNotice(
          <React.Fragment>
            L7 Policy <b>{l7policyName}</b> ({l7policyID}) is being deleted.
          </React.Fragment>
        )
        // fetch the listener again containing the new policy so it gets updated fast
        persistListener(loadbalancerID, listenerID)
          .then(() => {})
          .catch((error) => {})
      })
      .catch((error) => {
        addError(
          React.createElement(ErrorsList, {
            errors: errorMessage(error.response),
          })
        )
      })
  }

  const displayName = () => {
    const name = l7Policy.name || l7Policy.id
    if (disabled) {
      return (
        <span className="info-text">
          <CopyPastePopover
            text={name}
            size={20}
            sliceType="MIDDLE"
            shouldPopover={false}
            shouldCopy={false}
            bsClass="cp copy-paste-ids"
          />
        </span>
      )
    } else {
      return (
        <Link to="#" onClick={onL7PolicyClick}>
          <CopyPastePopover
            text={name}
            size={20}
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
    if (l7Policy.name) {
      if (disabled) {
        return (
          <div className="info-text">
            <CopyPastePopover
              text={l7Policy.id}
              size={12}
              sliceType="MIDDLE"
              bsClass="cp copy-paste-ids"
              shouldPopover={false}
            />
          </div>
        )
      } else {
        return (
          <CopyPastePopover
            text={l7Policy.id}
            size={12}
            sliceType="MIDDLE"
            bsClass="cp copy-paste-ids"
            searchTerm={searchTerm}
          />
        )
      }
    }
  }

  const l7RuleIDs = l7Policy.rules.map((l7rule) => l7rule.id)
  Log.debug("RENDER L7 Policy Item")
  return (
    <tr>
      <td className="snug-nowrap">
        {displayName()}
        {displayID()}
        <CopyPastePopover
          text={l7Policy.description}
          size={20}
          shouldCopy={false}
          shouldPopover={true}
          searchTerm={searchTerm}
        />
      </td>
      <td>{entityStatus}</td>
      <td>
        <StaticTags tags={l7Policy.tags} />
      </td>
      <td>{l7Policy.position}</td>
      <td>
        <MyHighlighter search={searchTerm}>{l7Policy.action}</MyHighlighter>
        {actionRedirect(l7Policy.action).map((redirect, index) => (
          <span className="display-flex" key={index}>
            <br />
            <b>{redirect.label}: </b>
            {redirect.value === "redirect_prefix" ||
            redirect.value === "redirect_url" ? (
              <CopyPastePopover
                text={l7Policy[redirect.value]}
                size={20}
                bsClass="cp label-right"
              />
            ) : (
              <span className="label-right">{l7Policy[redirect.value]}</span>
            )}
          </span>
        ))}
      </td>

      <td>
        {disabled ? (
          <span className="info-text">{l7Policy.rules.length}</span>
        ) : (
          <CachedInfoPopover
            popoverId={"l7rules-popover-" + l7Policy.id}
            buttonName={l7RuleIDs.length}
            title={
              <React.Fragment>
                L7 Rules
                <Link
                  to="#"
                  onClick={onL7PolicyClick}
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
                listenerID={listenerID}
                l7PolicyID={l7Policy.id}
                l7RuleIDs={l7RuleIDs}
                cachedl7RuleIDs={l7Policy.cached_rules}
              />
            }
          />
        )}
      </td>

      <td>
        <DropDownMenu buttonIcon={<span className="fa fa-cog" />}>
          <li>
            <SmartLink
              to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/${
                l7Policy.id
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
              to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/${
                l7Policy.id
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
  )
}

export default L7PolicyListItem
