import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { OverlayTrigger, Tooltip } from "react-bootstrap"
import { PrettyDate } from "lib/components/pretty_date"
import { PrettySize } from "lib/components/pretty_size"
import { ImageIcon } from "./icon"
import React from "react"

export const OwnerIcon = () => {
  const tooltip = <Tooltip id="ownerIconTooltip">Owned by this project</Tooltip>

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}
    >
      <i className="text-primary fa fa-fw fa-user" />
    </OverlayTrigger>
  )
}

export const SnapshotIcon = () => {
  const tooltip = <Tooltip id="snapshotIconTooltip">Snapshot</Tooltip>

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}
    >
      <i className="fa fa-fw fa-camera" />
    </OverlayTrigger>
  )
}

const Item = (props) => {
  let { image } = props
  const canCreateInstance = policy.isAllowed("compute:instance_create", {
    target: {
      project: { parent_id: props.project_parent_id },
      scoped_domain_name: props.scoped_domain_name,
    },
  })

  return (
    <tr className={image.isDeleting || image.isFetching ? "updating" : ""}>
      <td className="snug">
        <ImageIcon image={image} />
        {policy.isAllowed("image:image_owner", { image }) && <OwnerIcon />}
      </td>
      <td>
        <Link
          to={`/os-images/${props.activeTab}/${image.id}/show`}
          data-test="images"
        >
          {image.image_type == "snapshot" && <SnapshotIcon />}{" "}
          {image.name || image.id}
        </Link>
        {image.name && (
          <span className="info-text">
            <br />
            {image.id}
          </span>
        )}
      </td>
      <td>{image.disk_format}</td>
      <td>
        <PrettySize size={image.size} />
      </td>
      <td>
        <PrettyDate date={image.created_at} />
      </td>
      <td>{image.status}</td>
      <td className="snug">
        {(canCreateInstance ||
          policy.isAllowed("image:image_unpublish") ||
          policy.isAllowed("image:image_delete", { image })) && (
          <div className="btn-group">
            <button
              className="btn btn-default btn-sm dropdown-toggle"
              type="button"
              data-toggle="dropdown"
              aria-expanded={true}
            >
              <i className="fa fa-cog"></i>
            </button>
            <ul className="dropdown-menu dropdown-menu-right" role="menu">
              {props.activeTab !== "suggested" && canCreateInstance && (
                <li>
                  <a
                    href={`${props.launchInstanceUrl}?image_id=${image.id}`}
                    data-modal
                  >
                    Launch Instance
                  </a>
                </li>
              )}
              {props.activeTab == "suggested" && image.visibility == "shared" && (
                <li>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault()
                      props.handleAccept(image.id)
                    }}
                  >
                    Accept
                  </a>
                </li>
              )}
              {props.activeTab == "suggested" && image.visibility == "shared" && (
                <li>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault()
                      props.handleReject(image.id)
                    }}
                  >
                    Reject
                  </a>
                </li>
              )}
              {props.activeTab == "available" && (
                <li>
                  <Link
                    to={`/os-images/${props.activeTab}/${image.id}/members`}
                  >
                    Access Control
                  </Link>
                </li>
              )}
              {image.visibility != "private" &&
                policy.isAllowed("image:image_visibility_to_private", {
                  image,
                }) && (
                  <li>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault()
                        props.handleVisibilityChange(image.id, "private")
                      }}
                    >
                      Set to private
                    </a>
                  </li>
                )}
              {image.visibility != "public" &&
                policy.isAllowed("image:image_visibility_to_public", {
                  image,
                }) && (
                  <li>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault()
                        props.handleVisibilityChange(image.id, "public")
                      }}
                    >
                      Set to public
                    </a>
                  </li>
                )}
              {image.visibility != "shared" &&
                policy.isAllowed("image:image_visibility_to_shared", {
                  image,
                }) && (
                  <li>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault()
                        props.handleVisibilityChange(image.id, "shared")
                      }}
                    >
                      Set to shared
                    </a>
                  </li>
                )}
              {image.visibility != "community" &&
                policy.isAllowed("image:image_visibility_to_community", {
                  image,
                }) && (
                  <li>
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault()
                        props.handleVisibilityChange(image.id, "community")
                      }}
                    >
                      Set to community
                    </a>
                  </li>
                )}
              {policy.isAllowed("image:image_delete", { image }) && (
                <li>
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault()
                      props.handleDelete(image.id)
                    }}
                  >
                    Delete
                  </a>
                </li>
              )}
            </ul>
          </div>
        )}
      </td>
    </tr>
  )
}

export default Item
