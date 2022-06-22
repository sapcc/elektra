import React from "react"
import { Link } from "react-router-dom"
import { TransitionGroup } from "react-transition-group"
import { FadeTransition } from "lib/components/transitions"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import EntryItem from "./item"
import * as client from "../../client"
import { useGlobalState } from "../StateProvider"

const Entries = () => {
  const [filterTerm, setFilterTerm] = React.useState(null)
  const [state, dispatch] = useGlobalState()
  const mounted = React.useRef(false)

  React.useEffect(() => {
    mounted.current = true
    dispatch({ type: "request" })
    client
      .get("key-manager-ng/entries")
      .then(
        (items) =>
          mounted.current && dispatch({ type: "@entries/receive", items })
      )
      .catch(
        (error) =>
          mounted.current &&
          dispatch({ type: "@entries/error", error: error.message })
      )

    return () => (mounted.current = false)
  }, [dispatch])

  const handleDelete = React.useCallback(
    (id) => {
      dispatch({ type: "@entries/requestDelete", id })
      client
        .del(`key-manager-ng/entries/${id}`)
        .then(
          () => mounted.current && dispatch({ type: "@entries/delete", id })
        )
        .catch(
          (error) =>
            mounted.current &&
            dispatch({
              type: "@entries/deleteFailure",
              id,
              error: error.message,
            })
        )
    },
    [dispatch]
  )

  const filteredItems = React.useMemo(() => {
    if (!state.entries.items || state.entries.items.length === 0) return []
    if (!filterTerm || filterTerm === "") return state.entries.items
    return state.entries.items.filter(
      (item) =>
        (item.name && item.name.indexOf(filterTerm) >= 0) ||
        (item.description && item.description.indexOf(filterTerm) >= 0)
    )
  }, [state.entries.items, filterTerm])

  return (
    <div>
      <div className="toolbar">
        <TransitionGroup>
          {state.entries.items.length >= 4 && (
            <FadeTransition>
              <SearchField
                onChange={setFilterTerm}
                placeholder="name or description"
                text="Searches by name or description in visible entries list only.
                      Entering a search term will automatically start loading the next pages
                      and filter the loaded items using the search term. Emptying the search
                      input field will show all currently loaded items."
              />
            </FadeTransition>
          )}
        </TransitionGroup>

        {policy.isAllowed("key_manager_ng:entry_create") && (
          <div className="main-buttons">
            <Link to="/entries/new" className="btn btn-primary">
              Create new
            </Link>
          </div>
        )}
      </div>

      {!policy.isAllowed("key_manager_ng:entry_list") ? (
        <span>You are not allowed to see this page</span>
      ) : state.isFetching ? (
        <span className="spinner" />
      ) : (
        <table className="table entries">
          <thead>
            <tr>
              <th>Name</th>
              <th>Description</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {filteredItems && filteredItems.length > 0 ? (
              filteredItems.map((entry, index) => (
                <EntryItem
                  key={index}
                  entry={entry}
                  handleDelete={handleDelete}
                />
              ))
            ) : (
              <tr>
                <td colSpan="3">No Entries found.</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  )
}

export default Entries
