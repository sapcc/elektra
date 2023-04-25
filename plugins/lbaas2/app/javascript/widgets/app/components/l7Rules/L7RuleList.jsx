import React, { useState, useEffect, useMemo } from "react"
import HelpPopover from "../shared/HelpPopover"
import useL7Rule from "../../lib/hooks/useL7Rule"
import { useGlobalState } from "../StateProvider"
import { Table } from "react-bootstrap"
import ErrorPage from "../ErrorPage"
import L7RuleListItem from "./L7RuleListItem"
import { Tooltip } from "lib/components/Overlay"
import { SearchField } from "lib/components/search_field"
import { policy } from "lib/policy"
import { scope } from "lib/ajax_helper"
import SmartLink from "../shared/SmartLink"
import Log from "../shared/logger"
import { regexString } from "lib/tools/regex_string"
import { searchParamsToString } from "../../helpers/commonHelpers"

const L7RulesList = ({ props, loadbalancerID }) => {
  const { persistL7Rules, setSearchTerm } = useL7Rule()
  const listenerID = useGlobalState().listeners.selected
  const l7PolicyID = useGlobalState().l7policies.selected
  const state = useGlobalState().l7rules

  useEffect(() => {
    initialLoad()
  }, [l7PolicyID])

  const initialLoad = () => {
    if (l7PolicyID) {
      Log.debug("FETCH L7 RULES")
      persistL7Rules(loadbalancerID, listenerID, l7PolicyID, {})
        .then((data) => {})
        .catch((error) => {})
    }
  }

  const canCreate = useMemo(
    () =>
      policy.isAllowed("lbaas2:l7rule_create", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const search = (term) => {
    setSearchTerm(term)
  }

  const error = state.error
  const searchTerm = state.searchTerm
  const selected = state.selected
  const isLoading = state.isLoading
  const items = state.items

  const filterItems = (searchTerm, items) => {
    if (!searchTerm) return items
    // filter items
    if (selected) {
      return items.filter((i) => i.id == searchTerm.trim())
    } else {
      const regex = new RegExp(regexString(searchTerm.trim()), "i")
      return items.filter(
        (i) => `${i.id} ${i.type} ${i.value}`.search(regex) >= 0
      )
    }
  }

  const l7Rules = filterItems(searchTerm, items)
  return useMemo(() => {
    return (
      <>
        {l7PolicyID && (
          <>
            {error ? (
              <div className="l7rules subtable multiple-subtable-right">
                <ErrorPage
                  headTitle="L7 Rules"
                  error={error}
                  onReload={initialLoad}
                />
              </div>
            ) : (
              <div className="l7rules subtable multiple-subtable-right">
                <div className="display-flex multiple-subtable-header">
                  <h4>L7 Rules</h4>
                  <HelpPopover text="An L7 Rule is a single, simple logical test which returns either true or false. It consists of a rule type, a comparison type, a value, and an optional key that gets used depending on the rule type. An L7 rule must always be associated with an L7 policy." />
                </div>

                {!selected && (
                  <>
                    <div className="toolbar searchToolbar">
                      <SearchField
                        value={searchTerm}
                        onChange={(term) => search(term)}
                        placeholder="ID, type or value"
                        text="Searches by ID, type or value."
                      />

                      <div className="main-buttons">
                        <SmartLink
                          disabled={isLoading}
                          to={`/loadbalancers/${loadbalancerID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/new?${searchParamsToString(
                            props
                          )}`}
                          className="btn btn-primary btn-xs"
                          isAllowed={canCreate}
                          notAllowedText="Not allowed to create. Please check with your administrator."
                        >
                          New L7 Rule
                        </SmartLink>
                      </div>
                    </div>
                  </>
                )}

                <Table
                  className={
                    l7Rules.length > 0
                      ? "table table-hover l7rules"
                      : "table l7rules"
                  }
                  responsive
                >
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Status</th>
                      <th>Tags</th>
                      <th>
                        <div className="display-flex">
                          Type
                          <div className="margin-left">
                            <Tooltip
                              placement="top"
                              container="body"
                              content="Sorted by Type ASC"
                            >
                              <i className="fa fa-sort-asc" />
                            </Tooltip>
                          </div>
                          /Compare Type
                        </div>
                      </th>
                      <th>Invert</th>
                      <th>Key</th>
                      <th>Value</th>
                      <th className="snug"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {l7Rules && l7Rules.length > 0 ? (
                      l7Rules.map((l7Rule, index) => (
                        <L7RuleListItem
                          props={props}
                          listenerID={listenerID}
                          l7PolicyID={l7PolicyID}
                          l7Rule={l7Rule}
                          key={index}
                          searchTerm={searchTerm}
                          shouldPoll={l7Rules.length < 11}
                        />
                      ))
                    ) : (
                      <tr>
                        <td colSpan="10">
                          {isLoading ? (
                            <span className="spinner" />
                          ) : (
                            "No L7 Rules found."
                          )}
                        </td>
                      </tr>
                    )}
                  </tbody>
                </Table>
              </div>
            )}
          </>
        )}
      </>
    )
  }, [
    l7PolicyID,
    JSON.stringify(l7Rules),
    error,
    selected,
    isLoading,
    searchTerm,
    props,
  ])
}

export default L7RulesList
