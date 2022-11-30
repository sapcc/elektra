import React, { useEffect, useState, useMemo } from "react"
import { useDispatch, useGlobalState } from "../StateProvider"
import usePool from "../../lib/hooks/usePool"
import PoolItem from "./PoolItem"
import queryString from "query-string"
import { Link } from "react-router-dom"
import HelpPopover from "../shared/HelpPopover"
import { Tooltip, OverlayTrigger, Table } from "react-bootstrap"
import { addError } from "lib/flashes"
import Pagination from "../shared/Pagination"
import { SearchField } from "lib/components/search_field"
import { policy } from "lib/policy"
import { scope } from "lib/ajax_helper"
import SmartLink from "../shared/SmartLink"
import ErrorPage from "../ErrorPage"
import Log from "../shared/logger"
import { regexString } from "lib/tools/regex_string"
import { searchParamsToString } from "../../helpers/commonHelpers"

const PoolList = ({ props, loadbalancerID }) => {
  const dispatch = useDispatch()
  const {
    persistPools,
    persistPool,
    setSearchTerm,
    setSelected,
    onSelectPool,
  } = usePool()
  const state = useGlobalState().pools
  const [initialLoadDone, setInitialLoadDone] = useState(false)
  const [triggerFindSelected, setTriggerFindSelected] = useState(false)

  // when the load balancer id changes the state is reseted and a new load begins
  useEffect(() => {
    initialLoad()
  }, [loadbalancerID])

  // when pools are loaded we check if we have to select one of them
  useEffect(() => {
    if (initialLoadDone) {
      selectPoolFromURL()
      setInitialLoadDone(false)
    }
  }, [initialLoadDone])

  // if pool is selected check if exists on the state
  useEffect(() => {
    if (state.selected) {
      findSelectedPool()
    }
  }, [state.selected])

  useEffect(() => {
    if (triggerFindSelected) {
      findSelectedPool()
    }
  }, [triggerFindSelected])

  const initialLoad = () => {
    Log.debug("FETCH POOLS")
    // no add marker so we get always the first ones on loading the component
    persistPools(loadbalancerID, true, null)
      .then((data) => {
        setInitialLoadDone(true)
      })
      .catch((error) => {})
  }

  const selectPoolFromURL = (data) => {
    const values = queryString.parse(props.location.search)
    const id = values.pool
    if (id) {
      // pool was selected
      setSelected(id)
      // filter the pool list to show just the one item
      setSearchTerm(id)
    }
  }

  const findSelectedPool = () => {
    setTriggerFindSelected(false)
    const index = state.items.findIndex((item) => item.id == selected)

    if (index >= 0) {
      // pool already exist on the state
      return
    } else if (hasNext) {
      // set state to loading to fetch the requested pool
      dispatch({ type: "REQUEST_POOLS" })
      // No listener found in the current list. Fetch just the selected
      persistPool(loadbalancerID, selected)
        .then(() => {
          // trigger again find selected listener to produce a reload
          setTriggerFindSelected(true)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_POOLS_FAILURE", error: error })
        })
    } else {
      // something weird happend. We just show an error
      addError(
        <React.Fragment>
          Pool <b>{selected}</b> not found.
        </React.Fragment>
      )
    }
  }

  const canCreate = useMemo(
    () =>
      policy.isAllowed("lbaas2:pool_create", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const handlePaginateClick = (e, page) => {
    e.preventDefault()
    if (page === "all") {
      persistPools(loadbalancerID, false, { limit: 9999 }).catch((error) => {})
    } else {
      persistPools(loadbalancerID, false, {
        marker: state.marker,
      }).catch((error) => {})
    }
  }

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(props)
  }

  const search = (term) => {
    if (hasNext && !isLoading) {
      persistPools(loadbalancerID, false, { limit: 9999 }).catch((error) => {})
    }
    dispatch({ type: "SET_POOLS_SEARCH_TERM", searchTerm: term })
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
          `${i.id} ${i.name} ${i.description} ${i.protocol}`.search(regex) >= 0
      )
    }
  }

  const pools = filterItems(searchTerm, items)
  const isLoading = state.isLoading

  return useMemo(() => {
    Log.debug("RENDER pool list")
    return (
      <div className="details-section">
        <div className="display-flex">
          <h4>Pools</h4>
          <HelpPopover text="Object representing the grouping of members to which the listener forwards client requests. Note that a pool is associated with only one listener, but a listener might refer to several pools (and switch between them using layer 7 policies)." />
        </div>

        {error ? (
          <ErrorPage headTitle="Pools" error={error} onReload={initialLoad} />
        ) : (
          <React.Fragment>
            <div className="toolbar">
              {selected ? (
                <Link className="back-link" to="#" onClick={restoreUrl}>
                  <i className="fa fa-chevron-circle-left"></i>
                  Back to Pools
                </Link>
              ) : (
                <SearchField
                  value={searchTerm}
                  onChange={(term) => search(term)}
                  placeholder="name, ID, desc. or protocol"
                  text="Searches by name, ID,description or protocol. All pools will be loaded."
                />
              )}

              <div className="main-buttons">
                {!selected && (
                  <SmartLink
                    disabled={isLoading}
                    to={`/loadbalancers/${loadbalancerID}/pools/new?${searchParamsToString(
                      props
                    )}`}
                    className="btn btn-primary"
                    isAllowed={canCreate}
                    notAllowedText="Not allowed to create. Please check with your administrator."
                  >
                    New Pool
                  </SmartLink>
                )}
              </div>
            </div>

            <div className="table-responsive">
              <Table
                className={
                  selected
                    ? "table table-section pools"
                    : "table table-hover pools"
                }
                responsive
              >
                <thead>
                  <tr>
                    <th>
                      <div className="display-flex">
                        Name
                        <div className="margin-left">
                          <OverlayTrigger
                            placement="top"
                            overlay={
                              <Tooltip id="defalult-pool-tooltip">
                                Sorted by Name ASC
                              </Tooltip>
                            }
                          >
                            <i className="fa fa-sort-asc" />
                          </OverlayTrigger>
                        </div>
                        /ID/Description
                      </div>
                    </th>
                    <th>Status</th>
                    <th>Tags</th>
                    <th>Algorithm</th>
                    <th>Protocol</th>
                    <th>Session Persistence</th>
                    <th>Assigned to</th>
                    <th>TLS enabled/Secrets</th>
                    <th>Health Monitor</th>
                    <th>#Members</th>
                    <th className="snug"></th>
                  </tr>
                </thead>
                <tbody>
                  {pools && pools.length > 0 ? (
                    pools.map((pool, index) => (
                      <PoolItem
                        props={props}
                        pool={pool}
                        searchTerm={searchTerm}
                        key={index}
                        disabled={selected ? true : false}
                        shouldPoll={pools.length < 11}
                      />
                    ))
                  ) : (
                    <tr>
                      <td colSpan="9">
                        {isLoading ? (
                          <span className="spinner" />
                        ) : (
                          "No pools found."
                        )}
                      </td>
                    </tr>
                  )}
                </tbody>
              </Table>
            </div>

            {pools.length > 0 && !selected && (
              <Pagination
                isLoading={isLoading}
                items={state.items}
                hasNext={hasNext}
                handleClick={handlePaginateClick}
              />
            )}
          </React.Fragment>
        )}
      </div>
    )
  }, [
    JSON.stringify(pools),
    error,
    isLoading,
    searchTerm,
    selected,
    props,
    hasNext,
  ])
}

export default PoolList
