import { SearchField } from "lib/components/search_field"
import { Alert } from "react-bootstrap"
import { Link } from "react-router-dom"
import React from "react"
import * as apiClient from "../../apiClient"
import { useGlobalState, useDispatch } from "../../stateProvider"

/*
cached_object_type: "bgpvpn"
export_targets: []
id: "1e44fe36-4ea0-4fb2-8223-0a9bb7ca234a"
import_targets: []
local_pref: null
name: "test-vpn"
networks: []
ports: []
project_id: "f7bbfa9fbdb84ac2811452e3ef0f5431"
route_distinguishers: []
route_targets: []
routers: []
search_label: ""
shared: true
tenant_id: "f7bbfa9fbdb84ac2811452e3ef0f5431"
*/

const loadCachedObjectsAsMap = (ids) =>
  apiClient
    .get(`../../../../cache/objects-by-ids`, {
      ids,
    })
    .then((items) =>
      items.reduce((map, item) => {
        map[item.id] = item
        return map
      }, {})
    )

const BgpVpns = () => {
  const { bgpvpns, projects, routers } = useGlobalState()
  const dispatch = useDispatch()
  const [filter, setFilter] = React.useState()

  // const [projects, setProjects] = React.useState({})
  // const [routers, setRouters] = React.useState({})

  React.useEffect(() => {
    dispatch({ type: "REQUEST_BGP_VPNS" })
    apiClient
      .get("../../bgp-vpns")
      .then((data) =>
        dispatch({ type: "RECEIVE_BGP_VPNS", items: data.bgpvpns })
      )
      .catch((error) =>
        dispatch({ type: "RECEIVE_BGP_VPNS_ERROR", error: error.message })
      )
  }, [])

  React.useEffect(() => {
    if (!bgpvpns.items || bgpvpns.items.length === 0) return

    // load projects by ids from elektra cache
    dispatch({ type: "REQUEST_PROJECTS" })
    loadCachedObjectsAsMap(bgpvpns.items.map((i) => i.project_id)).then(
      (data) => dispatch({ type: "RECEIVE_PROJECTS", data })
    )

    // load routers from elektra cache
    dispatch({ type: "REQUEST_ROUTERS" })
    loadCachedObjectsAsMap(bgpvpns.items.map((i) => i.routers).flat()).then(
      (data) => dispatch({ type: "RECEIVE_ROUTERS", data })
    )
  }, [bgpvpns.items])

  const filteredItems = React.useMemo(() => {
    if (!filter || filter.length === 0) return bgpvpns.items
    return bgpvpns.items.filter(
      (i) => i.name.indexOf(filter) >= 0 || i.id.indexOf(filter) >= 0
    )
  }, [bgpvpns.items, filter])

  return (
    <React.Fragment>
      <div className="toolbar">
        <SearchField
          onChange={(term) => setFilter(term)}
          placeholder="name or ID"
          text="Filters by name or ID"
        />
      </div>
      {bgpvpns.isFetching ? (
        <span>
          <span className="spinner" />
          Loading...
        </span>
      ) : bgpvpns.error ? (
        <Alert bsStyle="danger">{bgpvpns.error}</Alert>
      ) : filteredItems.length === 0 ? (
        <span>No items found!</span>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Owning Project</th>
              <th>Associated Routers</th>
              <th>Shared</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {filteredItems.map((item, i) => (
              <tr key={i}>
                <td>
                  <Link to={`/${item.id}`}>{item.name}</Link>
                  <br />
                  <span className="info-text">{item.id}</span>
                </td>
                <td>
                  {projects.data[item.project_id] ? (
                    <React.Fragment>
                      <a href={`/_/${item.project_id}`} target="_blank">
                        {
                          projects.data[item.project_id].payload?.scope
                            ?.domain_name
                        }
                        /{projects.data[item.project_id].name}
                      </a>
                      <br />
                      <span className="info-text">{item.project_id}</span>
                    </React.Fragment>
                  ) : (
                    item.project_id
                  )}
                </td>
                <td>
                  {(item.routers || []).map((r, i) => (
                    <div key={i}>
                      {routers.data[r] ? (
                        <React.Fragment>
                          {routers.data[r].name}
                          <br />
                          <span className="info-text">{r}</span>
                        </React.Fragment>
                      ) : (
                        r
                      )}
                    </div>
                  ))}
                </td>
                <td>{`${item.shared}`}</td>
                <td></td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </React.Fragment>
  )
}

export default BgpVpns
