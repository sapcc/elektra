import React, { useEffect, useState, useRef, useMemo } from "react"
import { DefeatableLink } from "lib/components/defeatable_link"
import useL7Policy from "../../../lib/hooks/useL7Policy"
import useCommons from "../../../lib/hooks/useCommons"
import HelpPopover from "../shared/HelpPopover"
import L7PolicyListItem from "./L7PolicyListItem"
import { Table } from "react-bootstrap"
import { useDispatch, useGlobalState } from "../StateProvider"
import L7PolicySelected from "./L7PolicySelected"
import queryString from "query-string"
import ErrorPage from "../ErrorPage"
import { Tooltip, OverlayTrigger } from "react-bootstrap"
import { addError } from "lib/flashes"
import { SearchField } from "lib/components/search_field"
import { policy } from "policy"
import { scope } from "ajax_helper"
import SmartLink from "../shared/SmartLink"
import Log from "../shared/logger"
import { regexString } from 'lib/tools/regex_string';

const L7PolicyList = ({ props, loadbalancerID }) => {
  const dispatch = useDispatch()
  const {
    persistL7Policies,
    persistL7Policy,
    setSearchTerm,
    setSelected,
    reset,
    onSelectL7Policy,
  } = useL7Policy()
  const { searchParamsToString } = useCommons()
  const state = useGlobalState().l7policies
  const listenerID = useGlobalState().listeners.selected
  const listenerError = useGlobalState().listeners.error
  const [initialLoadDone, setInitialLoadDone] = useState(false)
  const [triggerFindSelected, setTriggerFindSelected] = useState(false)

  // when the listener id changes the state is reseted and a new load begins
  useEffect(() => {
    initialLoad()
    return () => {
      reset()
    }
  }, [listenerID])

  // when policies are loaded we check if we have to select one of them
  useEffect(() => {
    if (initialLoadDone) {
      selectL7PolicyFromURL()
      setInitialLoadDone(false)
    }
  }, [initialLoadDone])

  // if listener is selected check if exists on the state
  useEffect(() => {
    if (state.selected) {
      findSelectedL7Policy()
    }
  }, [state.selected])

  useEffect(() => {
    if (triggerFindSelected) {
      findSelectedL7Policy()
    }
  }, [triggerFindSelected])

  const initialLoad = () => {
    if (listenerID) {
      Log.debug("FETCH L7 POLICIES")
      persistL7Policies(loadbalancerID, listenerID, null)
        .then((data) => {
          setInitialLoadDone(true)
        })
        .catch((error) => {})
    }
  }

  const selectL7PolicyFromURL = () => {
    const values = queryString.parse(props.location.search)
    const id = values.l7policy
    if (id) {
      // policy was selected
      setSelected(id)
      // filter the policy list to show just the one item
      setSearchTerm(id)
    }
  }

  const findSelectedL7Policy = () => {
    setTriggerFindSelected(false)
    const index = state.items.findIndex((item) => item.id == selected)
    if (index >= 0) {
      return
    } else {
      // set state to loading
      dispatch({ type: "REQUEST_L7POLICIES" })
      // No listener found in the current list. Fetch just the selected
      persistL7Policy(loadbalancerID, listenerID, selected)
        .then(() => {
          // trigger again find selected listener
          setTriggerFindSelected(true)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_L7POLICIES_FAILURE", error: error })
        })
    }
  }

  const canCreate = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7policy_create", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectL7Policy(props)
  }

  const search = (term) => {
    setSearchTerm(term)
  }

  const error = state.error
  const hasNext = state.hasNext
  const searchTerm = state.searchTerm
  const selected = state.selected
  const items = state.items

  const filterItems = (searchTerm, items) => {
    if (!searchTerm) return items
    // filter items
    if (selected) {
      return items.filter((i) => i.id == searchTerm.trim())
    } else {
      const regex = new RegExp(regexString(searchTerm.trim()), "i")
      return items.filter(
        (i) =>
          `${i.id} ${i.name} ${i.description} ${i.action}`.search(regex) >= 0
      )
    }
  }

  const l7Policies = filterItems(searchTerm, items)
  const isLoading = state.isLoading
  return useMemo(() => {
    Log.debug("RENDER L7 POLICIES")
    return (
      <React.Fragment>
        {listenerID && !listenerError && (
          <React.Fragment>
            {error ? (
              <div
                className={
                  selected
                    ? "l7policies subtable multiple-subtable-left"
                    : "l7policies subtable"
                }
              >
                <ErrorPage
                  headTitle="L7 Policies"
                  error={error}
                  onReload={initialLoad}
                />
              </div>
            ) : (
              <div
                className={
                  selected
                    ? "l7policies subtable multiple-subtable-left"
                    : "l7policies subtable"
                }
              >
                <div className="display-flex multiple-subtable-header">
                  <h4>L7 Policies</h4>
                  <HelpPopover text="Collection of L7 rules that get logically ANDed together as well as a routing policy for any given HTTP or terminated HTTPS client requests which match said rules. An L7 Policy is associated with exactly one HTTP or terminated HTTPS listener." />
                </div>

                {selected && l7Policies.length == 1 ? (
                  l7Policies.map((l7Policy, index) => (
                    <div className="selected-l7policy" key={index}>
                      <L7PolicySelected
                        props={props}
                        listenerID={listenerID}
                        l7Policy={l7Policy}
                        onBackLink={restoreUrl}
                      />
                    </div>
                  ))
                ) : (
                  <React.Fragment>
                    <div className="toolbar searchToolbar">
                      <SearchField
                        value={searchTerm}
                        onChange={(term) => search(term)}
                        placeholder="name, ID, description or action"
                        text="Searches by name, ID, description or action."
                      />
                      <div className="main-buttons">
                        <SmartLink
                          disabled={isLoading}
                          to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/new?${searchParamsToString(
                            props
                          )}`}
                          className="btn btn-primary btn-xs"
                          isAllowed={canCreate}
                          notAllowedText="Not allowed to create. Please check with your administrator."
                        >
                          New L7 Policy
                        </SmartLink>
                      </div>
                    </div>

                    <Table
                      className={
                        l7Policies.length > 0
                          ? "table table-hover policies"
                          : "table policies"
                      }
                      responsive
                    >
                      <thead>
                        <tr>
                          <th>Name/ID/Description</th>
                          <th>State</th>
                          <th>Prov. Status</th>
                          <th>Tags</th>
                          <th>
                            <div className="display-flex">
                              Position
                              <div className="margin-left">
                                <OverlayTrigger
                                  placement="top"
                                  overlay={
                                    <Tooltip id="defalult-pool-tooltip">
                                      Sorted by Position ASC
                                    </Tooltip>
                                  }
                                >
                                  <i className="fa fa-sort-asc" />
                                </OverlayTrigger>
                              </div>
                            </div>
                          </th>
                          <th>Action/Redirect</th>
                          <th>#L7 Rules</th>
                          <th className="snug"></th>
                        </tr>
                      </thead>
                      <tbody>
                        {l7Policies && l7Policies.length > 0 ? (
                          l7Policies.map((l7Policy, index) => (
                            <L7PolicyListItem
                              props={props}
                              l7Policy={l7Policy}
                              searchTerm={searchTerm}
                              key={index}
                              listenerID={listenerID}
                              disabled={selected}
                            />
                          ))
                        ) : (
                          <tr>
                            <td colSpan="9">
                              {isLoading ? (
                                <span className="spinner" />
                              ) : (
                                "No L7 Policies found."
                              )}
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </Table>
                  </React.Fragment>
                )}
              </div>
            )}
          </React.Fragment>
        )}
      </React.Fragment>
    )
  }, [
    listenerID,
    listenerError,
    JSON.stringify(l7Policies),
    error,
    selected,
    isLoading,
    searchTerm,
    props,
  ])
}

export default L7PolicyList
