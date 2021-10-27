import { SearchField } from "lib/components/search_field"
import { Alert, MenuItem, Dropdown } from "react-bootstrap"
import { Link } from "react-router-dom"
import React from "react"
import * as apiClient from "../../apiClient"
import { useGlobalState, useDispatch } from "../../stateProvider"
import { useHistory } from "react-router-dom"

const BgpVpns = () => {
  const { bgpvpns, cachedProjects, cachedRouters } = useGlobalState()
  const cachedProjectsData = React.useMemo(
    () => cachedProjects.data || {},
    [cachedProjects.data]
  )
  const cachedRoutersData = React.useMemo(
    () => cachedRouters.data || {},
    [cachedRouters.data]
  )
  const dispatch = useDispatch()
  const [filter, setFilter] = React.useState()
  const history = useHistory()

  // load bgp vpns
  React.useEffect(() => {
    dispatch("bgpvpns", "request")
    apiClient
      .get("../../bgp-vpns")
      .then((data) => dispatch("bgpvpns", "receive", { items: data.bgpvpns }))
      .catch((error) => dispatch("bgpvpns", "error", { error }))
  }, [])

  // load objects from cache
  React.useEffect(() => {
    if (!bgpvpns.items) return

    const ids = bgpvpns.items.reduce(
      (list, i) => list.concat(i.routers, [i.project_id]),
      []
    )

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
        dispatch("cachedRouters", "receive", { data: data["router"] })
      })
  }, [bgpvpns.items])

  // filter items by name or id
  const filteredItems = React.useMemo(() => {
    if (!filter || filter.length === 0) return bgpvpns.items || []
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
      {!policy.isAllowed("networking:bgp_vpn_list") ? (
        <span>You are not allowed to see this page</span>
      ) : bgpvpns.isFetching ? (
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
                  {cachedProjectsData[item.project_id] ? (
                    <React.Fragment>
                      <a href={`/_/${item.project_id}`} target="_blank">
                        {
                          cachedProjectsData[item.project_id].payload?.scope
                            ?.domain_name
                        }
                        /{cachedProjectsData[item.project_id].name}
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
                      {cachedRoutersData[r] ? (
                        <React.Fragment>
                          {cachedRoutersData[r].name}
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
                <td>
                  <Dropdown id={`bgpvpns-dropdown-${item.id}`} pullRight>
                    <Dropdown.Toggle noCaret className="btn-sm">
                      <span className="fa fa-cog" />
                    </Dropdown.Toggle>
                    <Dropdown.Menu className="super-colors">
                      <MenuItem onClick={() => history.push(`/${item.id}/2`)}>
                        Manage Routers
                      </MenuItem>
                      <MenuItem onClick={() => history.push(`/${item.id}/3`)}>
                        Access Control
                      </MenuItem>
                    </Dropdown.Menu>
                  </Dropdown>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </React.Fragment>
  )
}

export default BgpVpns
