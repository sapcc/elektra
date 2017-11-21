import SecurityServiceItem from './item';
import { policy } from 'policy';
import { DefeatableLink } from 'lib/components/defeatable_link';
import { Popover, OverlayTrigger } from 'react-bootstrap';

const noCreatePermissionPopover = (
  <Popover id="popover-no-secure-service-create-permission" title="Missing Create Permission">
    You don't have permission to create a security service.
    Please check if you have the role sharedfilesystem_admin.
  </Popover>
);

export default class SecurityServiceList extends React.Component {
  componentDidMount() {
    if (this.props.active) { return this.props.loadSecurityServicesOnce(); }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.active) { return this.props.loadSecurityServicesOnce(); }
  }

  render() {
    return (
      <div>
        <div className='toolbar'>
          <DefeatableLink
            to='/security-services/new'
            className='btn btn-primary'
            disabled={!policy.isAllowed('shared_filesystem_storage:security_service_create')}>
            Create New
          </DefeatableLink>

          { !policy.isAllowed('shared_filesystem_storage:security_service_create') &&
            <span className="pull-right">
              <OverlayTrigger trigger="click" placement="top" rootClose overlay={noCreatePermissionPopover}>
                <a className='text-warning' href='#' onClick={(e) => e.preventDefault()}>
                  <i className='fa fa-fw fa-exclamation-triangle fa-2'></i>
                </a>
              </OverlayTrigger>
            </span>
          }
        </div>

        { this.props.isFetching ? (
          <div className='loadig'><span className='spinner'/>{'Loading...'}</div>
        ) : (
          <table className='table security-services'>
            <thead>
              <tr>
                <th>Name</th>
                <th>Type</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>

            <tbody>
              { this.props.securityServices.length===0 ? (
                <tr>
                  <td colSpan='5'>No Security Service found.</td>
                </tr>
              ) : ( this.props.securityServices.map((securityService) =>
                  <SecurityServiceItem
                    key={securityService.id}
                    securityService={securityService}
                    handleDelete={this.props.handleDelete}/>
                  )
              )}
            </tbody>
          </table>
        )}
      </div>
    );
  }
}
