import React from "react"
import PropTypes from "prop-types"
import { MenuItem, Dropdown } from "react-bootstrap"
import { useHistory, Link } from "react-router-dom"
import { Unit } from "lib/unit"
import TimeAgo from "../shared/TimeAgo"
import ItemsCount from "../shared/ItemsCount"
import { policy } from "lib/policy"
const unit = new Unit("B")

const Container = ({
  style,
  container,
  handleAccessControl,
  handleDelete,
  handleEmpty,
  handleProperties,
  canDelete,
  canEmpty,
  canShow,
  canShowAccessControl,
}) => {
  return (
    <div style={{ ...style }} className="flex-grid-row">
      <div className="flex-grid-cell flex-grid-cell-auto-width">
        <div>
          <span className="fa fa-fw fa-hdd-o" title="Container" />{" "}
          <Link
            to={`/containers/${container.name}/objects`}
            title="List Containers"
          >
            {container.name}
          </Link>{" "}
        </div>

        <ItemsCount count={container.count} />
      </div>

      <div className="flex-grid-cell flex-grid-cell-width-20">
        <TimeAgo date={container.last_modified} originDate />
      </div>
      <div className="flex-grid-cell flex-grid-cell-width-20">
        {unit.format(container.bytes)}
      </div>

      <div className="flex-grid-cell snug">
        <Dropdown id={`container-dropdown-${container.name}`} pullRight>
          <Dropdown.Toggle noCaret className="btn-sm">
            <span className="fa fa-cog" />
          </Dropdown.Toggle>
          <Dropdown.Menu className="super-colors">
            {canShow && (
              <MenuItem onClick={handleProperties}>Properties</MenuItem>
            )}
            {canShowAccessControl && (
              <MenuItem onClick={handleAccessControl}>Access Control</MenuItem>
            )}
            {(canShow || canShowAccessControl) && <MenuItem divider />}
            {container.count > 0 && canEmpty && (
              <MenuItem onClick={handleEmpty}>Empty</MenuItem>
            )}
            {canDelete && <MenuItem onClick={handleDelete}>Delete</MenuItem>}
          </Dropdown.Menu>
        </Dropdown>
      </div>
    </div>
    // <tr style={{ ...style, display: "flex" }}>
    //   <td style={{ flex: 1 }} className="name-with-icon">
    //     <span className="fa fa-fw fa-hdd-o" title="Container" />{" "}
    //     <Link
    //       to={`/containers/${container.name}/objects`}
    //       title="List Containers"
    //     >
    //       {container.name}
    //     </Link>{" "}
    //     <br />
    //     <ItemsCount count={container.count} />
    //   </td>
    //   <td style={{ flex: 1 }}>
    //     <TimeAgo date={container.last_modified} originDate />
    //   </td>
    //   <td style={{ flex: 1 }}>{unit.format(container.bytes)}</td>

    //   <td style={{ flex: 1 }} className="snug">
    //     <Dropdown id={`container-dropdown-${container.name}`} pullRight>
    //       <Dropdown.Toggle noCaret className="btn-sm">
    //         <span className="fa fa-cog" />
    //       </Dropdown.Toggle>
    //       <Dropdown.Menu className="super-colors">
    //         {canShow && (
    //           <MenuItem onClick={handleProperties}>Properties</MenuItem>
    //         )}
    //         {canShowAccessControl && (
    //           <MenuItem onClick={handleAccessControl}>Access Control</MenuItem>
    //         )}
    //         {(canShow || canShowAccessControl) && <MenuItem divider />}
    //         {container.count > 0 && canEmpty && (
    //           <MenuItem onClick={handleEmpty}>Empty</MenuItem>
    //         )}
    //         {canDelete && <MenuItem onClick={handleDelete}>Delete</MenuItem>}
    //       </Dropdown.Menu>
    //     </Dropdown>
    //   </td>
    // </tr>
  )
}

Container.propTypes = {
  style: PropTypes.object,
  container: PropTypes.object.isRequired,
  handleProperties: PropTypes.func.isRequired,
  handleAccessControl: PropTypes.func.isRequired,
  handleEmpty: PropTypes.func.isRequired,
  handleDelete: PropTypes.func.isRequired,
  canDelete: PropTypes.bool.isRequired,
  canEmpty: PropTypes.bool.isRequired,
  canShow: PropTypes.bool.isRequired,
  canShowAccessControl: PropTypes.bool.isRequired,
}

export default Container
