import React from "react"
import * as apiClient from "../../apiClient"
import { useDispatch, useGlobalState } from "../../stateProvider"
import { Alert } from "react-bootstrap"
import AddRouterAssociation from "./addRouterAssociation"
import AssociationItem from "./associationItem"

const reducer = (state = { items: [] }, action = {}) => {
  switch (action.type) {
    case "load":
      return { ...state, isFetching: true, error: null }
    case "receive":
      return {
        ...state,
        items: action.items,
        isFetching: false,
        updatedAt: Date.now(),
      }
    case "error":
      return {
        ...state,
        isFetching: false,
        error: action.error,
      }
    default:
      return state
  }
}

const BgpVpnRouters = ({ bgpvpn }) => {
  const cachedRoutersData = useGlobalState("cachedRouters").data || {}
  const availableRouters = useGlobalState("availableRouters")
  const bgpvpns = useGlobalState("bgpvpns")
  const bgpvpnRouterIDs = React.useMemo(() => bgpvpn.routers || [])
  const globalDispatch = useDispatch()
  const [addMode, setAddMode] = React.useState(false)
  const [isAdding, setIsAdding] = React.useState(false)

  const [associations, associationDispatch] = React.useReducer(
    reducer,
    reducer()
  )

  const url = React.useMemo(
    () => `../../bgp-vpns/${bgpvpn.id}/router-associations`,
    [bgpvpn]
  )

  // delete router association
  const handleDeleteAssociation = React.useCallback(
    (id) =>
      apiClient
        .del(`${url}/${id}`)
        .then(() => {
          // remove from associations
          if (!associations.items) return
          const index = associations.items.findIndex((i) => i.id === id)
          if (index < 0) return
          const items = associations.items
          let association = items[index]
          items.splice(index, 1)
          associationDispatch({ type: "receive", items })
          return association
        })
        .then((association) => {
          if (!bgpvpns.items) return
          if (!bgpvpn || !bgpvpn.routers) return
          const index = bgpvpn.routers.indexOf(association?.router_id)
          if (index < 0) return
          const indexOfBgpvpn = bgpvpns.items.findIndex(
            (i) => i.id === bgpvpn.id
          )
          if (indexOfBgpvpn < 0) return
          const items = bgpvpns.items.slice()
          const routers = bgpvpn.routers.slice()
          routers.splice(index, 1)
          items[indexOfBgpvpn] = { ...bgpvpn, routers }

          globalDispatch("bgpvpns", "receive", { items })
        })
        .catch((error) =>
          associationDispatch({ type: "error", error: error.message })
        ),
    [url, associations, bgpvpns, bgpvpn]
  )

  // create router association
  const handleAddAssociation = React.useCallback(
    (router_id) => {
      setAddMode(false)
      setIsAdding(true)
      apiClient
        .post(`${url}`, { router_id })
        .then((data) => {
          const items = associations.items.slice()
          items.unshift(data.router_association)
          associationDispatch({ type: "receive", items })
        })
        .catch((error) =>
          associationDispatch({ type: "error", error: error.message })
        )
        .finally(() => setIsAdding(false))
    },
    [url, associations]
  )

  // load bgp vpn router associations
  React.useEffect(() => {
    associationDispatch({ type: "load" })
    apiClient
      .get(url)
      .then((data) => {
        associationDispatch({
          type: "receive",
          items: data.router_associations,
        })
      })
      .catch((error) =>
        associationDispatch({ type: "error", error: error.message })
      )
  }, [])

  // load available routers (for selectbox)
  // available routers are also used for subnet infos
  React.useEffect(() => {
    // return if already loaded
    if (availableRouters.isFetching) return

    // check if associations haave routers which are not in avialableRouters state
    // if so then reload availableRouters
    if (availableRouters.data && associations.items) {
      const routerIDs = Object.keys(availableRouters.data)
      const available = associations.items.every(
        (a) => routerIDs.indexOf(a.router_id) >= 0
      )
      if (available) return
    }

    if (!associations.items) return

    globalDispatch("availableRouters", "request")
    apiClient
      .get(`../../bgp-vpns/routers`)
      .then((data) => {
        const routersByID = data.routers.reduce((map, r) => {
          map[r.id] = r
          return map
        }, {})
        globalDispatch("availableRouters", "receive", { data: routersByID })
      })
      .catch((error) =>
        globalDispatch("availableRouters", "receive", { error: error.message })
      )
  }, [availableRouters, associations.items])

  const foreignRouterIDs = React.useMemo(() => {
    const ids = associations.items.map((i) => i.router_id)
    return bgpvpnRouterIDs.filter((id) => ids.indexOf(id) < 0)
  }, [associations.items, bgpvpnRouterIDs])

  const availableAssociationRouters = React.useMemo(() => {
    if (!availableRouters.data || !associations.items) return []
    return Object.values(availableRouters.data).filter(
      (router) =>
        associations.items.findIndex((i) => i.router_id === router.id) < 0
    )
  }, [availableRouters.data, associations.items])

  if (associations.isFetching || routers.isFetching)
    return (
      <span>
        <span className="spinner" />
        Loading...
      </span>
    )

  return (
    <React.Fragment>
      {associations.error && (
        <Alert bsStyle="danger">{associations.error}</Alert>
      )}

      <table className="table">
        <thead>
          <tr>
            <th>Name/ID</th>
            <th>Subnets</th>
            <th className="snug"></th>
          </tr>
        </thead>
        <tbody>
          {/* normal user has no access to shared associations. For
            this case we consider the routers field of bgpvpn (with canEdit = false).
          */}
          {associations.items.length === 0 && foreignRouterIDs.length === 0 ? (
            <tr>
              <td colSpan="3">
                <span>No router associations found!</span>
              </td>
            </tr>
          ) : (
            <React.Fragment>
              {associations.items.map((association, i) => (
                <AssociationItem
                  key={i}
                  onDelete={() => handleDeleteAssociation(association.id)}
                  routerId={association.router_id}
                  cachedData={cachedRoutersData[association.router_id]}
                  router={
                    availableRouters.data &&
                    availableRouters.data[association.router_id]
                  }
                  isFetching={availableRouters.isFetching}
                />
              ))}
              {foreignRouterIDs.map((routerId, i) => (
                <AssociationItem
                  key={i}
                  routerId={routerId}
                  cachedData={cachedRoutersData[routerId]}
                />
              ))}
            </React.Fragment>
          )}

          <tr>
            <td colSpan="2">
              <div className="pull-right">
                {isAdding ? (
                  <span>
                    <span className="spinner" />
                    adding...
                  </span>
                ) : (
                  addMode &&
                  (availableRouters.data ? (
                    <AddRouterAssociation
                      routers={availableAssociationRouters}
                      onSelect={(routerID) => handleAddAssociation(routerID)}
                    />
                  ) : (
                    <span className="spinner" />
                  ))
                )}
              </div>
            </td>
            <td className="snug">
              {addMode ? (
                <button
                  onClick={() => setAddMode(false)}
                  className="btn btn-default btn-sm"
                >
                  Cancel
                </button>
              ) : (
                <button
                  disabled={isAdding}
                  onClick={() => setAddMode(true)}
                  className="btn btn-success btn-sm"
                >
                  <i className="fa fa-plus fa-fw" />
                </button>
              )}
            </td>
          </tr>
        </tbody>
      </table>
      {/* <pre>{JSON.stringify(routersDeepData, null, 2)}</pre> */}
    </React.Fragment>
  )
}

export default BgpVpnRouters
