import { SearchField } from "lib/components/search_field"
import { Alert, MenuItem, Dropdown } from "react-bootstrap"
import { Link } from "react-router-dom"
import React, { useCallback } from "react"
import * as apiClient from "../../apiClient"
import { useGlobalState, useDispatch } from "../../stateProvider"
import { useHistory } from "react-router-dom"
import { confirm } from "lib/dialogs"

const Interconnections = () => {
  const { interconnections, cachedBgpVpns, cachedInterconnections } =
    useGlobalState()
  const dispatch = useDispatch()
  const [filter, setFilter] = React.useState()
  const history = useHistory()

  const cachedInterconnectionsData = React.useMemo(
    () => cachedInterconnections.data || {},
    [cachedInterconnections.data]
  )
  const cachedBgpVpnsData = React.useMemo(
    () => cachedBgpVpns.data || {},
    [cachedBgpVpns.data]
  )

  // load bgp vpns
  React.useEffect(() => {
    dispatch("interconnections", "request")
    apiClient
      .get("../../interconnections")
      .then((data) =>
        dispatch("interconnections", "receive", {
          items: data.interconnections,
        })
      )
      .catch((error) =>
        dispatch("interconnections", "error", { error: error.message })
      )
  }, [])

  const deleteInterconnection = useCallback((id) => {
    confirm(`Do you really want to delete the interconnection ${id}?`)
      .then(() => {
        dispatch("interconnections", "patch", {
          name: "items",
          id,
          values: { isDeleting: true },
        })
        apiClient
          .del(`../../interconnections/${id}`)
          .then(() => {
            dispatch("interconnections", "remove", { name: "items", id })
          })
          .catch((error) => {
            dispatch("interconnections", "error", { error: error.message })
            dispatch("interconnections", "patch", {
              name: "items",
              id,
              values: { isDeleting: false },
            })
          })
      })
      .catch((_aborted) => null)
  }, [])

  // filter items by name or id
  const filteredItems = React.useMemo(() => {
    if (!filter || filter.length === 0) return interconnections.items || []
    return interconnections.items.filter(
      (i) => i.name.indexOf(filter) >= 0 || i.id.indexOf(filter) >= 0
    )
  }, [interconnections.items, filter])

  // load objects from cache
  React.useEffect(() => {
    if (!interconnections.items) return

    // consider interconnections, bgpvpns and projects
    const ids = interconnections.items
      .reduce(
        (list, i) =>
          list.concat([
            i.remote_interconnection_id,
            i.project_id,
            i.local_resource_id,
            i.remote_resource_id,
          ]),
        []
      )
      .filter((v, i, a) => a.indexOf(v) === i) // uniq

    apiClient
      .get(`../../../../cache/objects-by-ids`, {
        ids,
      })
      .then((items) => {
        // group items by cache_type and i
        // result: {"project": {id: item}, "router": {id: item}}
        const data = items.reduce((map, i) => {
          map[i.cached_object_type] = map[i.cached_object_type] || {}
          map[i.cached_object_type][i.id] = i
          return map
        }, {})

        // set data to global state
        dispatch("cachedProjects", "receive", { data: data["project"] })
        dispatch("cachedInterconnections", "receive", {
          data: data["interconnection"],
        })
        dispatch("cachedBgpVpns", "receive", {
          data: data["bgpvpn"],
        })
      })
  }, [interconnections.items])

  return (
    <React.Fragment>
      <div className="toolbar">
        <SearchField
          onChange={(term) => setFilter(term)}
          placeholder="name or ID"
          text="Filters by name or ID"
        />

        <div className="main-buttons">
          {policy.isAllowed("networking:interconnection_create") && (
            <Link to="/new" className="btn btn-primary">
              New interconnection
            </Link>
          )}
        </div>
      </div>
      {interconnections.error && (
        <Alert bsStyle="danger">{interconnections.error}</Alert>
      )}

      {!policy.isAllowed("networking:interconnection_list") ? (
        <span>You are not allowed to see this page</span>
      ) : interconnections.isFetching ? (
        <span>
          <span className="spinner" />
          Loading...
        </span>
      ) : filteredItems.length === 0 ? (
        <span>No items found!</span>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Local BGP VPN</th>
              <th>Remote BGP VPN</th>
              <th>Remote Region</th>
              <th>Remote Interconnection</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {filteredItems.map((item, i) => (
              <tr key={i} className={item.isDeleting ? "updating" : ""}>
                <td>
                  <Link to={`/${item.id}`}>{item.name}</Link>
                  <br />
                  <span className="info-text">{item.id}</span>
                </td>
                <td>
                  {cachedBgpVpnsData[item.local_resource_id] ? (
                    <React.Fragment>
                      {cachedBgpVpnsData[item.local_resource_id].name}
                      <br />
                      <span className="info-text">
                        {item.local_resource_id}
                      </span>
                    </React.Fragment>
                  ) : (
                    item.local_resource_id
                  )}
                </td>
                <td>
                  {cachedBgpVpnsData[item.remote_resource_id] ? (
                    <React.Fragment>
                      {cachedBgpVpnsData[item.remote_resource_id].name}
                      <br />
                      <span className="info-text">
                        {item.remote_resource_id}
                      </span>
                    </React.Fragment>
                  ) : (
                    item.remote_resource_id
                  )}
                </td>
                <td>{item.remote_region}</td>
                <td>
                  {" "}
                  {cachedInterconnectionsData[
                    item.remote_interconnection_id
                  ] ? (
                    <React.Fragment>
                      {
                        cachedInterconnectionsData[
                          item.remote_interconnection_id
                        ].name
                      }
                      <br />
                      <span className="info-text">
                        {item.remote_interconnection_id}
                      </span>
                    </React.Fragment>
                  ) : (
                    item.remote_interconnection_id
                  )}
                </td>
                <td>
                  {!item.isDeleting &&
                    policy.isAllowed("networking:interconnection_delete") && (
                      <Dropdown
                        id={`interconnections-dropdown-${item.id}`}
                        pullRight
                      >
                        <Dropdown.Toggle noCaret className="btn-sm">
                          <span className="fa fa-cog" />
                        </Dropdown.Toggle>
                        <Dropdown.Menu className="super-colors">
                          {policy.isAllowed(
                            "networking:interconnection_delete"
                          ) && (
                            <>
                              {/* <MenuItem divider /> */}
                              <MenuItem onClick={() => deleteBgpvpn(item.id)}>
                                Delete
                              </MenuItem>
                            </>
                          )}
                        </Dropdown.Menu>
                      </Dropdown>
                    )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </React.Fragment>
  )
}

export default Interconnections
