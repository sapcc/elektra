import React from "react"
import { useEffect, useState, useMemo } from "react"
import useListener from "../../lib/hooks/useListener"
import ListenerItem from "./ListenerItem"
import queryString from "query-string"
import { Link } from "react-router-dom"
import HelpPopover from "../shared/HelpPopover"
import { useDispatch, useGlobalState } from "../StateProvider"
import ErrorPage from "../ErrorPage"
import { Table } from "react-bootstrap"
import { Tooltip } from "lib/components/Overlay"
import { addError } from "lib/flashes"
import Pagination from "../shared/Pagination"
import { SearchField } from "lib/components/search_field"
import { policy } from "lib/policy"
import { scope } from "lib/ajax_helper"
import SmartLink from "../shared/SmartLink"
import Log from "../shared/logger"
import { regexString } from "lib/tools/regex_string"
import { searchParamsToString } from "../../helpers/commonHelpers"

const ListenerList = ({ props, loadbalancerID }) => {
  const dispatch = useDispatch()
  const {
    persistListeners,
    persistListener,
    setSelected,
    setSearchTerm,
    onSelectListener,
  } = useListener()
  const state = useGlobalState().listeners
  const [initialLoadDone, setInitialLoadDone] = useState(false)
  const [triggerFindSelectedListener, setTriggerFindSelectedListener] =
    useState(false)

  // when the load balancer id changes the state is reseted and a new load begins
  useEffect(() => {
    initialLoad()
  }, [loadbalancerID])

  // when listeners are loaded we check if we have to select one of them
  useEffect(() => {
    if (initialLoadDone) {
      selectListenerFromURL()
      setInitialLoadDone(false)
    }
  }, [initialLoadDone])

  // if listener is selected check if exists on the state
  useEffect(() => {
    if (state.selected) {
      findSelectedListener()
    }
  }, [state.selected])

  useEffect(() => {
    if (triggerFindSelectedListener) {
      findSelectedListener()
    }
  }, [triggerFindSelectedListener])

  const initialLoad = () => {
    Log.debug("LISTENER INITIAL FETCH")
    // no add marker so we get always the first ones on loading the component
    persistListeners(loadbalancerID, true, null)
      .then((data) => {
        setInitialLoadDone(true)
      })
      .catch((error) => {})
  }

  // when initial load happens we check if a listener is per url selected
  const selectListenerFromURL = () => {
    const values = queryString.parse(props.location.search)
    const id = values.listener
    if (id) {
      // Listener was selected
      setSelected(id)
      // filter the listener list to show just the one item
      setSearchTerm(id)
    }
  }

  const findSelectedListener = () => {
    setTriggerFindSelectedListener(false)
    const index = state.items.findIndex((item) => item.id == selected)

    if (index >= 0) {
      return
    } else if (hasNext) {
      // set state to loading
      dispatch({ type: "REQUEST_LISTENERS" })
      // No listener found in the current list.
      persistListener(loadbalancerID, selected)
        .then(() => {
          // trigger again find selected listener
          setTriggerFindSelectedListener(true)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_LISTENERS_FAILURE", error: error })
        })
    } else {
      // something weird happend. We just show an error
      addError(
        <>
          Listener <b>{selected}</b> not found.
        </>
      )
    }
  }

  const canCreate = useMemo(
    () =>
      policy.isAllowed("lbaas2:listener_create", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const handlePaginateClick = (e, page) => {
    e.preventDefault()
    if (page === "all") {
      persistListeners(loadbalancerID, false, {
        limit: 9999,
      }).catch((error) => {})
    } else {
      persistListeners(loadbalancerID, false, {
        marker: state.marker,
      }).catch((error) => {})
    }
  }

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectListener(props)
  }

  const search = (term) => {
    if (hasNext && !isLoading) {
      persistListeners(loadbalancerID, false, {
        limit: 9999,
      }).catch((error) => {})
    }
    setSearchTerm(term)
  }

  const error = state.error
  const hasNext = state.hasNext
  const items = state.items
  const selected = state.selected
  const searchTerm = state.searchTerm

  const filterItems = (searchTerm, items) => {
    if (!searchTerm) return items
    // filter items
    if (selected) {
      return items.filter((i) => i.id == searchTerm.trim())
    } else {
      const regex = new RegExp(regexString(searchTerm.trim()), "i")
      return items.filter(
        (i) =>
          `${i.id} ${i.name} ${i.description} ${i.protocol} ${i.protocol_port}`.search(
            regex
          ) >= 0
      )
    }
  }

  const listeners = filterItems(searchTerm, items)
  const isLoading = state.isLoading
  return useMemo(() => {
    Log.debug("RENDER Listener list")
    return (
      <div className="details-section">
        <div className="display-flex">
          <h4>Listeners</h4>
          <HelpPopover text="Object representing the listening endpoint of a load balanced service. TCP / UDP port, as well as protocol information and other protocol- specific details are attributes of the listener. Notably, though, the IP address is not." />
        </div>
        {error ? (
          <ErrorPage
            headTitle="Listeners"
            error={error}
            onReload={initialLoad}
          />
        ) : (
          <>
            <div className="toolbar">
              {selected ? (
                <Link className="back-link" to="#" onClick={restoreUrl}>
                  <i className="fa fa-chevron-circle-left"></i>
                  Back to Listeners
                </Link>
              ) : (
                <SearchField
                  value={searchTerm}
                  onChange={(term) => search(term)}
                  placeholder="name, ID, desc., protocol, port"
                  text="Searches by name, ID, description, protocol or protocol port. All listeners will be loaded."
                />
              )}
              <div className="main-buttons">
                {!selected && (
                  <SmartLink
                    disabled={isLoading}
                    to={`/loadbalancers/${loadbalancerID}/listeners/new?${searchParamsToString(
                      props
                    )}`}
                    className="btn btn-primary"
                    isAllowed={canCreate}
                    notAllowedText="Not allowed to create. Please check with your administrator."
                  >
                    New Listener
                  </SmartLink>
                )}
              </div>
            </div>

            <div className="table-responsive">
              <Table
                className={
                  selected
                    ? "table table-section listeners"
                    : "table table-hover listeners"
                }
                responsive
              >
                <thead>
                  <tr>
                    <th>
                      <div className="display-flex">
                        Name
                        <div className="margin-left">
                          <Tooltip
                            placement="top"
                            container="body"
                            content="Sorted by Name ASC"
                          >
                            <i className="fa fa-sort-asc" />
                          </Tooltip>
                        </div>
                        /ID/Description
                      </div>
                    </th>
                    <th>Status</th>
                    <th>Tags</th>
                    <th>Protocol/Client Auth/Secrets</th>
                    <th>Protocol Port</th>
                    <th>Default Pool</th>
                    <th>Connection Limit</th>
                    <th>Insert Headers</th>
                    <th>#L7 Policies</th>
                    <th className="snug"></th>
                  </tr>
                </thead>
                <tbody>
                  {listeners && listeners.length > 0 ? (
                    listeners.map((listener, index) => (
                      <ListenerItem
                        props={props}
                        listener={listener}
                        searchTerm={searchTerm}
                        key={index}
                        disabled={selected ? true : false}
                        shouldPoll={listeners.length < 11}
                      />
                    ))
                  ) : (
                    <tr>
                      <td colSpan="11">
                        {isLoading ? (
                          <span className="spinner" />
                        ) : (
                          "No listeners found."
                        )}
                      </td>
                    </tr>
                  )}
                </tbody>
              </Table>
            </div>

            {listeners.length > 0 && !selected && (
              <Pagination
                isLoading={isLoading}
                items={state.items}
                hasNext={hasNext}
                handleClick={handlePaginateClick}
              />
            )}
          </>
        )}
      </div>
    )
  }, [
    JSON.stringify(listeners),
    error,
    isLoading,
    searchTerm,
    selected,
    props,
    hasNext,
  ])
}

export default ListenerList
