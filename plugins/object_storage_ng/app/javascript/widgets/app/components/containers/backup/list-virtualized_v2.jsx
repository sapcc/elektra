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
import { AutoSizer } from "react-virtualized-auto-sizer"
import { useTable, useBlockLayout } from "react-table"

function Table({ columns, data }) {
  // Use the state and functions returned from useTable to build your UI

  const defaultColumn = React.useMemo(
    () => ({
      width: 150,
    }),
    []
  )

  const scrollBarSize = React.useMemo(() => scrollbarWidth(), [])

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    totalColumnsWidth,
    prepareRow,
  } = useTable(
    {
      columns,
      data,
      defaultColumn,
    },
    useBlockLayout
  )

  const RenderRow = React.useCallback(
    ({ index, style }) => {
      const row = rows[index]
      prepareRow(row)
      return (
        <div
          {...row.getRowProps({
            style,
          })}
          className="tr"
        >
          {row.cells.map((cell) => {
            return (
              <div {...cell.getCellProps()} className="td">
                {cell.render("Cell")}
              </div>
            )
          })}
        </div>
      )
    },
    [prepareRow, rows]
  )

  // Render the UI for your table
  return (
    <div {...getTableProps()} className="table">
      <div>
        {headerGroups.map((headerGroup) => (
          <div {...headerGroup.getHeaderGroupProps()} className="tr">
            {headerGroup.headers.map((column) => (
              <div {...column.getHeaderProps()} className="th">
                {column.render("Header")}
              </div>
            ))}
          </div>
        ))}
      </div>

      <div {...getTableBodyProps()}>
        <FixedSizeList
          height={400}
          itemCount={rows.length}
          itemSize={35}
          width={totalColumnsWidth + scrollBarSize}
        >
          {RenderRow}
        </FixedSizeList>
      </div>
    </div>
  )
}

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

  const Row = React.useCallback(
    ({ index, style }) => {
      const item = items[index]
      return (
        <Container
          key={index}
          style={style}
          container={item}
          handleAccessControl={() => handleAccessControl(item.name)}
          handleProperties={() => handleProperties(item.name)}
          handleEmpty={() => handleEmpty(item.name)}
          handleDelete={() => handleDelete(item.name)}
          {...permissions}
        />
      )
    },
    [items, permissions]
  )

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
          <div className="flex-grid" style={{ height: "100vh" }}>
            <div className="flex-grid-row flex-grid-header-row">
              <div className="flex-grid-cell flex-grid-cell-auto-width">
                Container name
              </div>
              <div className="flex-grid-cell flex-grid-cell-width-20">
                Last modified
              </div>
              <div className="flex-grid-cell flex-grid-cell-width-20">
                Total size
              </div>
              <div className="flex-grid-cell flex-grid-cell-width-context-menu"></div>
            </div>
            <AutoSizer>
              {({ height, width }) => (
                <List
                  outerTagName="div"
                  height={height}
                  itemCount={items.length}
                  itemSize={55}
                  style={{ display: "block", maxWidth: width }}
                  width={width}
                >
                  {Row}
                </List>
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
