import SecurityServiceItem from "./item"
import { policy } from "lib/policy"
import { DefeatableLink } from "lib/components/defeatable_link"
import { Popover, OverlayTrigger } from "react-bootstrap"
import React from "react"

const CreateNewButton = () => {
  if (!policy.isAllowed("shared_filesystem_storage:share_network_create")) {
    const popover = (
      <Popover
        id="popover-no-secure-service-create-permission"
        title="Missing Create Permission"
      >
        You don't have permission to create a security service. Please check if
        you have the role sharedfilesystem_admin.
      </Popover>
    )

    return (
      <OverlayTrigger
        overlay={popover}
        placement="top"
        delayShow={300}
        delayHide={150}
      >
        <button className="btn btn-primary disabled">
          <i className="fa fa-fw fa-exclamation-triangle fa-2"></i> Create New
        </button>
      </OverlayTrigger>
    )
  }

  return (
    <DefeatableLink to="/security-services/new" className="btn btn-primary">
      Create New
    </DefeatableLink>
  )
}

export default class SecurityServiceList extends React.Component {
  componentDidMount() {
    if (this.props.active) {
      return this.props.loadSecurityServicesOnce()
    }
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    if (nextProps.active) {
      return this.props.loadSecurityServicesOnce()
    }
  }

  render() {
    return (
      <React.Fragment>
        <div className="toolbar">
          <div className="main-buttons">
            <CreateNewButton />
          </div>
        </div>

        {this.props.isFetching ? (
          <div className="loadig">
            <span className="spinner" />
            {"Loading..."}
          </div>
        ) : (
          <table className="table security-services">
            <thead>
              <tr>
                <th>Name</th>
                <th>Type</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>

            <tbody>
              {this.props.securityServices.length === 0 ? (
                <tr>
                  <td colSpan="5">No Security Service found.</td>
                </tr>
              ) : (
                this.props.securityServices.map((securityService) => (
                  <SecurityServiceItem
                    key={securityService.id}
                    securityService={securityService}
                    handleDelete={this.props.handleDelete}
                  />
                ))
              )}
            </tbody>
          </table>
        )}
      </React.Fragment>
    )
  }
}
