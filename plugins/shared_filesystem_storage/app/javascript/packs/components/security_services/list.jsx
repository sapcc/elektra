import SecurityServiceItem from './item';
import { Link } from 'react-router-dom';

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
        { true && //this.props.permissions.create ?
          <div className='toolbar'>
            <Link to='/security-services/new' className='btn btn-primary'>Create New</Link>
          </div>
        }

        { this.props.isFetching ? (
          <div><span className='spinner'/>{'Loading...'}</div>
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
                  <td> colSpan='5'>No Security Service found.</td>
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
