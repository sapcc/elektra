/* eslint-disable react/no-unescaped-entities */
import SecurityServiceItem from "./item"
import { policy } from "lib/policy"
import { DefeatableLink } from "lib/components/defeatable_link"
import { Popover } from "lib/components/Overlay"
import React from "react"

const CreateNewButton = () => {
  if (!policy.isAllowed("shared_filesystem_storage:share_network_create")) {
    return (
      <Popover
        title="Missing Create Permission"
        content="You don't have permission to create a security service. Please check if
        you have the role sharedfilesystem_admin."
        placement="top"
      >
        <button className="btn btn-primary disabled">
          <i className="fa fa-fw fa-exclamation-triangle fa-2"></i> Create New
        </button>
      </Popover>
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
      <>
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
      </>
    )
  }
}
