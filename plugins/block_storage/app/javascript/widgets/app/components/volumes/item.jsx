import { Link } from "react-router-dom"
import { scope } from "lib/ajax_helper"
import { Highlighter } from "react-bootstrap-typeahead"
import { OverlayTrigger, Tooltip } from "react-bootstrap"
import * as constants from "../../constants"

const MyHighlighter = ({ search, children }) => {
  if (!search || !children) return children
  return <Highlighter search={search}>{children + ""}</Highlighter>
}

export default class Volume extends React.Component {
  UNSAFE_componentWillReceiveProps(nextProps) {
    // stop polling if status has changed from creating to something else
    this.pendignState(nextProps) ? this.startPolling() : this.stopPolling()
  }

  componentDidMount() {
    if (this.pendignState()) this.startPolling()
  }

  componentWillUnmount() {
    // stop polling on unmounting
    this.stopPolling()
  }

  startPolling = () => {
    // do not create a new polling interval if already polling
    if (this.polling) return
    this.polling = setInterval(
      () => this.props.reloadVolume(this.props.volume.id),
      5000
    )
  }

  stopPolling = () => {
    clearInterval(this.polling)
    this.polling = null
  }

  handleDelete = (e) => {
    e.preventDefault()
    this.props.deleteVolume(this.props.volume.id)
  }

  handleForceDelete = (e) => {
    e.preventDefault()
    this.props.forceDeleteVolume(this.props.volume.id)
  }

  pendignState = (props = this.props) => {
    return constants.VOLUME_PENDING_STATUS.indexOf(props.volume.status) >= 0
  }

  handleDetach = (e) => {
    e.preventDefault()
    if (
      !this.props.volume.attachments ||
      this.props.volume.attachments.length == 0
    ) {
      return
    }

    this.props.detachVolume(
      this.props.volume.id,
      this.props.volume.attachments[0].attachment_id
    )
  }

  render() {
    let { volume, searchTerm = "" } = this.props
    return (
      <tr className={`state-${volume.status}`}>
        <td>
          {(volume.bootable === true || volume.bootable === "true") && (
            <OverlayTrigger
              placement="top"
              overlay={<Tooltip id="bootable-volume">Bootable Volume</Tooltip>}
            >
              <i className="fa fa-hdd-o"></i>
            </OverlayTrigger>
          )}
        </td>
        <td>
          {policy.isAllowed("block_storage:volume_get", {}) ? (
            <Link to={`/volumes/${volume.id}/show`}>
              <MyHighlighter search={searchTerm}>
                {volume.name || volume.id}
              </MyHighlighter>
            </Link>
          ) : (
            <MyHighlighter search={searchTerm}>{volume.name}</MyHighlighter>
          )}
          {volume.name && (
            <React.Fragment>
              <br />
              <span className="info-text">
                <MyHighlighter search={searchTerm}>{volume.id}</MyHighlighter>
              </span>
            </React.Fragment>
          )}
        </td>
        <td>{volume.availability_zone}</td>
        <td>{volume.description}</td>
        <td>{volume.size}</td>
        <td>
          {volume &&
            volume.attachments &&
            volume.attachments.length > 0 &&
            volume.attachments.map((attachment, index) => (
              <div key={index}>
                <a
                  href={`/${scope.domain}/${scope.project}/compute/instances/${attachment.server_id}`}
                  data-modal={true}
                >
                  {attachment.server_name || attachment.server_id}
                </a>
                &nbsp;on {attachment.device}
                {attachment.server_name && (
                  <React.Fragment>
                    <br />
                    <span className="info-text">{attachment.server_id}</span>
                  </React.Fragment>
                )}
              </div>
            ))}
        </td>
        <td>
          {this.pendignState() && <span className="spinner" />}
          <MyHighlighter search={searchTerm}>{volume.status}</MyHighlighter>
        </td>
        <td className="snug">
          {(policy.isAllowed("block_storage:volume_delete", {
            target: { scoped_domain_name: scope.domain },
          }) ||
            policy.isAllowed("block_storage:volume_update", {
              target: { scoped_domain_name: scope.domain },
            })) && (
            <div className="btn-group">
              <button
                className="btn btn-default btn-sm dropdown-toggle"
                disabled={this.pendignState()}
                type="button"
                data-toggle="dropdown"
                aria-expanded={true}
              >
                <span className="fa fa-cog"></span>
              </button>

              <ul className="dropdown-menu dropdown-menu-right" role="menu">
                {policy.isAllowed("block_storage:volume_update", {
                  target: { scoped_domain_name: scope.domain },
                }) && (
                  <li>
                    <Link to={`/volumes/${volume.id}/edit`}>Edit</Link>
                  </li>
                )}
                {volume.status == "available" && (
                  <li>
                    <Link to={`/volumes/${volume.id}/snapshots/new`}>
                      Create Snapshot
                    </Link>
                  </li>
                )}
                {policy.isAllowed("block_storage:volume_create", {
                  target: { scoped_domain_name: scope.domain },
                }) && (
                  <li>
                    <Link to={`/volumes/${volume.id}/new`}>Clone Volume</Link>
                  </li>
                )}
                {volume.attachments &&
                volume.attachments.length == 0 &&
                policy.isAllowed("compute:attach_volume", {
                  target: { scoped_domain_name: scope.domain },
                }) ? (
                  <React.Fragment>
                    <li className="divider"></li>
                    <li>
                      <Link to={`/volumes/${volume.id}/attachments/new`}>
                        Attach
                      </Link>
                    </li>
                  </React.Fragment>
                ) : (
                  policy.isAllowed("compute:detach_volume", {
                    target: { scoped_domain_name: scope.domain },
                  }) && (
                    <React.Fragment>
                      <li className="divider"></li>
                      <li>
                        <a href="#" onClick={this.handleDetach}>
                          Detach
                        </a>
                      </li>
                    </React.Fragment>
                  )
                )}
                {policy.isAllowed("block_storage:volume_delete", {
                  target: { scoped_domain_name: scope.domain },
                }) &&
                  volume.status != "in-use" && (
                    <React.Fragment>
                      <li className="divider"></li>
                      <li>
                        <a href="#" onClick={this.handleDelete}>
                          Delete
                        </a>
                      </li>
                    </React.Fragment>
                  )}
                {(policy.isAllowed("block_storage:volume_reset_status") ||
                  policy.isAllowed("block_storage:volume_extend_size")) && (
                  <React.Fragment>
                    <li className="divider"></li>
                    {policy.isAllowed("block_storage:volume_reset_status") && (
                      <li>
                        <Link to={`/volumes/${volume.id}/reset-status`}>
                          Reset Status
                        </Link>
                      </li>
                    )}
                    {policy.isAllowed("block_storage:volume_extend_size") && (
                      <li>
                        <Link to={`/volumes/${volume.id}/extend-size`}>
                          Extend Size
                        </Link>
                      </li>
                    )}
                  </React.Fragment>
                )}
                {policy.isAllowed("image:image_create") && (
                  <li>
                    <Link to={`/volumes/${volume.id}/images/new`}>
                      Upload To Image
                    </Link>
                  </li>
                )}
                {policy.isAllowed("block_storage:volume_force_delete") && (
                  <li>
                    <a href="#" onClick={this.handleForceDelete}>
                      Force Delete
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
}
