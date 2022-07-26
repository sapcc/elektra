import React from "react"
import { MenuItem, Dropdown } from "react-bootstrap"
import { useHistory, Link } from "react-router-dom"
import { Unit } from "lib/unit"
const unit = new Unit("B")
import TimeAgo from "../shared/TimeAgo"
import ItemsCount from "../shared/ItemsCount"

const Container = ({
  container,
  canViewAccessControl,
  canDelete,
  canShow,
  canEmpty,
}) => {
  const history = useHistory()
  const handleSelect = React.useCallback(
    (e) => {
      switch (e) {
        case "1":
          return history.push(`/containers/${container.name}/properties`)
        case "2":
          return history.push(`/containers/${container.name}/access-control`)
        case "3":
          return history.push(`/containers/${container.name}/empty`)
        case "4":
          return history.push(`/containers/${container.name}/delete`)
        default:
          return
      }
    },
    [container, history]
  )

  return (
    <tr>
      <td className="name-with-icon">
        <span className="fa fa-fw fa-hdd-o" title="Container" />{" "}
        <Link
          to={`/containers/${container.name}/objects`}
          title="List Containers"
        >
          {container.name}
        </Link>{" "}
        <br />
        <ItemsCount count={container.count} />
      </td>
      <td>
        <TimeAgo date={container.last_modified} originDate />
      </td>
      <td>{unit.format(container.bytes)}</td>

      <td className="snug">
        <Dropdown
          id={`container-dropdown-${container.name}`}
          pullRight
          onSelect={handleSelect}
        >
          <Dropdown.Toggle noCaret className="btn-sm">
            <span className="fa fa-cog" />
          </Dropdown.Toggle>
          <Dropdown.Menu className="super-colors">
            {canShow && <MenuItem eventKey="1">Properties</MenuItem>}
            {canViewAccessControl && (
              <MenuItem eventKey="2">Access Control</MenuItem>
            )}
            {(canShow || canViewAccessControl) && <MenuItem divider />}
            {container.count > 0 && canEmpty && (
              <MenuItem eventKey="3">Empty</MenuItem>
            )}
            {canDelete && <MenuItem eventKey="4">Delete</MenuItem>}
          </Dropdown.Menu>
        </Dropdown>
      </td>
    </tr>
  )
}
export default Container
