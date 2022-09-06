import React from "react"
import styled from "styled-components"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"
import { Link } from "react-router-dom"
import ItemsCount from "../shared/ItemsCount"
import TimeAgo from "../shared/TimeAgo"
import useVirtualizedTable from "../shared/VirtualizedTable"
import { Unit } from "lib/unit"
const unit = new Unit("B")
import { policy } from "lib/policy"
import { MenuItem, Dropdown } from "react-bootstrap"
import { SearchField } from "lib/components/search_field"
import CapabilitiesPopover from "../capabilities/popover"
import VirtualizedTable from "../shared/VirtualizedTable"

const Styles = styled.div`
  .virtualized-table-td,
  .virtualized-table-th {
    padding: 5px 8px;
  }

  .virtualized-table-td {
    border-top: 1px solid #ddd;
  }

  .virtualized-table-th {
    border-bottom: 1px solid #ddd;
    font-weight: bold;
  }

  .virtualized-table-sortable-icon-disabled {
    opacity: 0.45;
  }
`

const List = () => {
  const containers = useGlobalState("containers")
  const { loadContainersOnce } = useActions()

  React.useEffect(() => {
    loadContainersOnce()
  }, [loadContainersOnce])

  const columns = React.useMemo(
    () => [
      { label: "Container name", accessor: "name", sortable: "text" },
      { label: "Last modified", accessor: "last_modified", width: "20%" },
      {
        label: "Total size",
        accessor: "bytes",
        width: "20%",
        sortable: true,
      },
      { width: "60" },
    ],
    []
  )

  const handleAccessControl = React.useCallback(() => null)
  const handleDelete = React.useCallback(() => null)
  const handleEmpty = React.useCallback(() => null)
  const handleProperties = React.useCallback(() => null)

  const items = containers.items

  const Row = React.useCallback(
    ({ column1, column2, column3, column4, item }) => {
      column1(
        <>
          <span className="fa fa-fw fa-hdd-o" title="Container" />{" "}
          <Link to={`/containers/${item.name}/objects`} title="List Containers">
            {item.name}
          </Link>{" "}
          <br />
          <ItemsCount count={item.count} />
        </>
      )

      column2(<TimeAgo date={item.last_modified} originDate />)

      column3(unit.format(item.bytes))

      column4(
        <Dropdown key={3} id={`container-dropdown-${item.name}`} pullRight>
          <Dropdown.Toggle noCaret className="btn-sm">
            <span className="fa fa-cog" />
          </Dropdown.Toggle>
          <Dropdown.Menu className="super-colors">
            {
              /*canShow*/ true && (
                <MenuItem onClick={handleProperties}>Properties</MenuItem>
              )
            }
            {
              /*canShowAccessControl*/ true && (
                <MenuItem onClick={handleAccessControl}>
                  Access Control
                </MenuItem>
              )
            }
            {/*(canShow || canShowAccessControl)*/ true && <MenuItem divider />}
            {item.count > 0 && /*canEmpty*/ true && (
              <MenuItem onClick={handleEmpty}>Empty</MenuItem>
            )}
            {
              /*canDelete*/ true && (
                <MenuItem onClick={handleDelete}>Delete</MenuItem>
              )
            }
          </Dropdown.Menu>
        </Dropdown>
      )
    },
    []
  )

  return (
    <Styles>
      <React.Fragment>
        <div className="toolbar">
          <SearchField
            onChange={(term) => null /* setSearchTerm(term)*/}
            placeholder="name"
            text="Filters by name"
          />

          <div className="main-buttons">
            {
              /*policy.isAllowed("object_storage_ng:container_create")*/ true && (
                <React.Fragment>
                  <CapabilitiesPopover />
                  <button
                    className="btn btn-link"
                    onClick={(e) => null /*load()*/}
                  >
                    <i className="fa fa-refresh" />
                  </button>
                  <Link to="/containers/new" className="btn btn-primary">
                    Create new
                  </Link>
                </React.Fragment>
              )
            }
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
          <VirtualizedTable
            height={400}
            width={1140}
            rowHeight={50}
            columns={columns}
            data={containers.items || []}
            renderRow={Row}
            showHeader
          />
        )}
      </React.Fragment>
    </Styles>
  )
}

export default List
