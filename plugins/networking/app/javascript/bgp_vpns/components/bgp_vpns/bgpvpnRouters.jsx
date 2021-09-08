import React from "react"
import * as apiClient from "../../apiClient"
import { useGlobalState } from "../../stateProvider"

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

const Item = ({ routerId, cachedRoutersData, canEdit }) => {
  return (
    <tr>
      <td>
        {cachedRoutersData[routerId] ? (
          <div>
            {cachedRoutersData[routerId].name}
            <br />

            <span className="info-text">
              Scope: {cachedRoutersData[routerId].payload?.scope?.domain_name}/
              {cachedRoutersData[routerId].payload?.scope?.project_name}
              <br />
              ID: {routerId}
            </span>
          </div>
        ) : (
          routerId
        )}
      </td>
      <td className="snug">
        {canEdit && (
          <button
            onClick={() => console.log("remove")}
            className="btn btn-default btn-sm"
          >
            <i className="fa fa-trash fa-fw" />
          </button>
        )}
      </td>
    </tr>
  )
}

const BgpVpnRouters = ({ bgpvpn }) => {
  const cachedRoutersData = useGlobalState("routers").data
  const bgpvpnRouterIDs = React.useMemo(() => bgpvpn.routers || [])

  const [associations, associationDispatch] = React.useReducer(
    reducer,
    reducer()
  )
  const [routers, routersDispatch] = React.useReducer(reducer, reducer())

  const url = React.useMemo(
    () => `../../bgp-vpns/${bgpvpn.id}/router-associations`,
    [bgpvpn]
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
      .catch((error) => associationDispatch({ type: "error", error }))
  }, [])

  React.useEffect(() => {
    routersDispatch({ type: "load" })
    apiClient
      .get(`../../bgp-vpns/routers`)
      .then((data) => {
        routersDispatch({ type: "receive", items: data.routers })
      })
      .catch((error) => routersDispatch({ type: "error", error }))
  }, [])

  const forbiddenRouterIDs = React.useMemo(() => {
    const ids = associations.items.map((i) => i.router_id)
    return bgpvpnRouterIDs.filter((id) => ids.indexOf(id) < 0)
  }, [associations.items, bgpvpnRouterIDs])

  console.log("===", routers, associations, forbiddenRouterIDs)

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

      {associations.items.length === 0 && forbiddenRouterIDs.length === 0 && (
        <span>No router associations found!</span>
      )}

      <table className="table">
        <tbody>
          {/* normal user has no access to shared associations. For
            this case we consider the routers field of bgpvpn (with canEdit = false).
          */}
          {associations.items.map((association, i) => (
            <Item
              key={i}
              routerId={association.router_id}
              cachedRoutersData={cachedRoutersData}
              canEdit={true}
            />
          ))}
          {forbiddenRouterIDs.map((routerId, i) => (
            <Item
              key={i}
              routerId={routerId}
              cachedRoutersData={cachedRoutersData}
              canEdit={false}
            />
          ))}

          <tr>
            <td></td>
            <td className="snug">
              <button
                onClick={() => console.log("add")}
                className="btn btn-success btn-sm"
              >
                <i className="fa fa-plus fa-fw" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      {/* <pre>{JSON.stringify(routersDeepData, null, 2)}</pre> */}
    </React.Fragment>
  )
}

export default BgpVpnRouters
