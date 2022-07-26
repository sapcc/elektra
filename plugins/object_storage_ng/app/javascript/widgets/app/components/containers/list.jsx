import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import Container from "./item"
import React from "react"
import CapabilitiesPopover from "../capabilities/popover"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"

// import ContainerProperties from "./properties"
// import DeleteContainer from "./delete"
// import EmptyContainer from "./empty"
// import NewContainer from "./new"
// import ContainerAccessControl from "./accessControl"

import Router from "./router"

const Containers = ({ objectStoreEndpoint }) => {
  const [searchTerm, setSearchTerm] = React.useState()
  const containers = useGlobalState("containers")
  const { loadContainersOnce } = useActions()

  // policy rules do not require container
  // so we can do the checks for all items at once
  const policyRules = React.useMemo(() => {
    if (!policy) return {}
    return {
      canDelete: policy.isAllowed("object_storage_ng:container_delete"),
      canEmpty: policy.isAllowed("object_storage_ng:container_empty"),
      canShow: policy.isAllowed("object_storage_ng:container_get"),
      canViewAccessControl: policy.isAllowed(
        "object_storage_ng:container_show_access_control"
      ),
    }
  }, [policy])

  React.useEffect(() => {
    if (!policy.isAllowed("object_storage_ng:container_list")) return
    loadContainersOnce()
  }, [loadContainersOnce])

  const items = React.useMemo(() => {
    if (!containers.items) return []
    if (!searchTerm) return containers.items
    return containers.items.filter((i) => i.name.includes(searchTerm))
  }, [containers.items, searchTerm])

  return (
    <React.Fragment>
      <Router objectStoreEndpoint={objectStoreEndpoint} />
      <div className="toolbar">
        <SearchField
          onChange={(term) => setSearchTerm(term)}
          placeholder="name"
          text="Filters by name"
        />

        <div className="main-buttons">
          {policy.isAllowed("object_storage_ng:container_create") && (
            <React.Fragment>
              <CapabilitiesPopover />
              <button className="btn btn-link" onClick={(e) => load()}>
                <i className="fa fa-refresh" />
              </button>
              <Link to="/containers/new" className="btn btn-primary">
                Create new
              </Link>
            </React.Fragment>
          )}
        </div>
      </div>
      {!policy.isAllowed("object_storage_ng:container_list") ? (
        <span>You are not allowed to see this page</span>
      ) : containers.isFetching ? (
        <span>
          <span className="spinner" />
          Loading...
        </span>
      ) : items.length === 0 ? (
        <span>No Containers found.</span>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>Container name</th>
              <th>Last modified</th>
              <th>Total size</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, index) => (
              <Container key={index} container={item} {...policyRules} />
            ))}
          </tbody>
        </table>
      )}
    </React.Fragment>
  )
}

export default Containers
