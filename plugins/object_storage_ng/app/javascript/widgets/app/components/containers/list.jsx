import React from "react"
import PropTypes from "prop-types"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"
import { Link, useHistory } from "react-router-dom"
import ItemsCount from "../shared/ItemsCount"
import TimeAgo from "../shared/TimeAgo"
import { Unit } from "lib/unit"
const unit = new Unit("B")
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import CapabilitiesPopover from "../capabilities/popover"
import VirtualizedTable from "lib/components/VirtualizedTable"
import ContextMenu from "lib/components/ContextMenuPopover"

const Table = ({ data, onMenuAction }) => {
  const columns = React.useMemo(
    () => [
      {
        label: "Container name",
        accessor: "name",
        sortable: "text",
        // filterable: true,
      },
      {
        label: "Last modified",
        accessor: "last_modified",
        width: "20%",
        sortable: "date",
      },
      {
        label: "Total size",
        accessor: "bytes",
        width: "20%",
        sortable: true,
      },
      { width: "60px" },
    ],
    []
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

  const Row = React.useCallback(({ Row, item }) => {
    return (
      <Row>
        <Row.Column>
          <span className="fa fa-fw fa-hdd-o" title="Container" />{" "}
          <Link to={`/containers/${item.name}/objects`} title="List Containers">
            {item.name}
          </Link>
          <br />
          <ItemsCount count={item.count} />
        </Row.Column>
        <Row.Column>
          <TimeAgo date={item.last_modified} originDate />
        </Row.Column>
        <Row.Column>{unit.format(item.bytes)}</Row.Column>
        <Row.Column>
          <ContextMenu>
            {permissions.canShow && (
              <ContextMenu.Item
                onClick={() => onMenuAction("properties", item)}
              >
                Properties
              </ContextMenu.Item>
            )}
            {permissions.canShowAccessControl && (
              <ContextMenu.Item
                onClick={() => onMenuAction("accessControl", item)}
              >
                Access Control
              </ContextMenu.Item>
            )}
            {(permissions.canShow || permissions.canShowAccessControl) && (
              <ContextMenu.Item divider />
            )}
            {item.count > 0 && permissions.canEmpty && (
              <ContextMenu.Item onClick={() => onMenuAction("empty", item)}>
                Empty
              </ContextMenu.Item>
            )}
            {permissions.canDelete && (
              <ContextMenu.Item onClick={() => onMenuAction("delete", item)}>
                Delete
              </ContextMenu.Item>
            )}
          </ContextMenu>

          {/* <Dropdown key={3} id={`container-dropdown-${item.name}`} pullRight>
            <Dropdown.Toggle noCaret className="btn-sm">
              <span className="fa fa-cog" />
            </Dropdown.Toggle>

            <Dropdown.Menu className="super-colors">
              {permissions.canShow && (
                <MenuItem onClick={() => onMenuAction("properties", item)}>
                  Properties
                </MenuItem>
              )}
              {permissions.canShowAccessControl && (
                <MenuItem onClick={() => onMenuAction("accessControl", item)}>
                  Access Control
                </MenuItem>
              )}
              {(permissions.canShow || permissions.canShowAccessControl) && (
                <MenuItem divider />
              )}
              {item.count > 0 && permissions.canEmpty && (
                <MenuItem onClick={() => onMenuAction("empty", item)}>
                  Empty
                </MenuItem>
              )}
              {permissions.canDelete && (
                <MenuItem onClick={() => onMenuAction("delete", item)}>
                  Delete
                </MenuItem>
              )}
            </Dropdown.Menu>
          </Dropdown> */}
        </Row.Column>
      </Row>
    )
  }, [])

  return (
    <VirtualizedTable
      height="max"
      rowHeight={50}
      columns={columns}
      data={data || []}
      renderRow={Row}
      showHeader
      bottomOffset={160} // footer height
    />
  )
}

Table.propTypes = {
  data: PropTypes.arrayOf(PropTypes.object),
  onMenuAction: PropTypes.func,
}

const List = () => {
  const containers = useGlobalState("containers")
  const { loadContainersOnce } = useActions()
  const history = useHistory()

  React.useEffect(() => {
    loadContainersOnce()
  }, [loadContainersOnce])

  const handleMenuAction = React.useCallback(
    (action, item) => {
      switch (action) {
        case "accessControl":
          return history.push(`/containers/${item.name}/access-control`)
        case "empty":
          return history.push(`/containers/${item.name}/empty`)
        case "delete":
          return history.push(`/containers/${item.name}/delete`)
        case "properties":
          return history.push(`/containers/${item.name}/properties`)
      }
    },
    [history.push]
  )

  const items = containers.items

  return (
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
        <div style={{ marginTop: 15 }}>
          <Table data={containers.items} onMenuAction={handleMenuAction} />
        </div>
      )}
    </React.Fragment>
  )
}

export default List
