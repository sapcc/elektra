import React from "react"
import PropTypes from "prop-types"
import { Link, useHistory } from "react-router-dom"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import Container from "./item"
import CapabilitiesPopover from "../capabilities/popover"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"

import { FixedSizeList as List } from "react-window"
import { Column, Table, SortDirection, AutoSizer } from "react-virtualized"
import styles from "react-virtualized/styles.css"

console.log(styles)
// import ContainerProperties from "./properties"
// import DeleteContainer from "./delete"
// import EmptyContainer from "./empty"
// import NewContainer from "./new"
// import ContainerAccessControl from "./accessControl"

const Containers = () => {
  console.log("Containers")
  const history = useHistory()
  const [searchTerm, setSearchTerm] = React.useState()
  const containers = useGlobalState("containers")
  const { loadContainersOnce } = useActions()

  React.useEffect(() => {
    if (!policy.isAllowed("object_storage_ng:container_list")) return
    loadContainersOnce()
  }, [loadContainersOnce])

  const items = React.useMemo(() => {
    console.log("get items")
    if (!containers.items) return []
    if (!searchTerm) return containers.items
    return containers.items.filter((i) => i.name.includes(searchTerm))
  }, [containers.items, searchTerm])

  const handleDelete = React.useCallback(
    (name) => history.push(`/containers/${name}/delete`),
    [history.push]
  )

  const handleEmpty = React.useCallback(
    (name) => history.push(`/containers/${name}/empty`),
    [history.push]
  )

  const handleAccessControl = React.useCallback(
    (name) => history.push(`/containers/${name}/access-control`),
    [history.push]
  )

  const handleProperties = React.useCallback(
    (name) => history.push(`/containers/${name}/properties`),
    [history.push]
  )

  const permissions = React.useMemo(() => {
    if (!policy) return {}
    return {
      canDelete: policy.isAllowed("object_storage_ng:container_delete"),
      canEmpty: policy.isAllowed("object_storage_ng:container_empty"),
      canShow: policy.isAllowed("object_storage_ng:container_get"),
      canShowAccessControl: policy.isAllowed(
        "object_storage_ng:container_show_access_control"
      ),
    }
  }, [policy])

  return React.useMemo(
    () => (
      <React.Fragment>
        {console.log("render containers")}
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
          <div style={{ height: 400 }}>
            <AutoSizer>
              {({ height, width }) => (
                <Table
                  className="table"
                  width={width}
                  height={height}
                  headerHeight={20}
                  rowHeight={30}
                  sort={() => null}
                  sortBy={"name"}
                  // sortDirection={"dest"}
                  rowCount={items.length}
                  rowGetter={({ index }) => items[index]}
                >
                  <Column label="Name" dataKey="name" width={200} />
                  <Column width={300} label="Description" dataKey="name" />
                </Table>
              )}
            </AutoSizer>
          </div>

          // <table className="table">
          //   <thead>
          //     <tr>
          //       <th>Container name</th>
          //       <th>Last modified</th>
          //       <th>Total size</th>
          //       <th></th>
          //     </tr>
          //   </thead>
          //   <tbody>
          //     {items.map((item, index) => (
          //       <Container
          //         key={index}
          //         container={item}
          //         handleAccessControl={() => handleAccessControl(item.name)}
          //         handleProperties={() => handleProperties(item.name)}
          //         handleEmpty={() => handleEmpty(item.name)}
          //         handleDelete={() => handleDelete(item.name)}
          //         {...permissions}
          //       />
          //     ))}
          //   </tbody>
          // </table>
        )}
      </React.Fragment>
    ),
    [items, containers.isFetching]
  )
}

export default Containers
