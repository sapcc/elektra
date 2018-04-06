import Parents from './parents';
import Users from './users';
import Groups from '../containers/groups';

class ProjectDetails extends React.Component {

  projectInfo = () => {
    const {name,id} = this.props.project
    if (name != '' && id != '' && typeof name !== 'undefined' && typeof id !== 'undefined') {
      return(
        <React.Fragment>
          {this.props.project.name}
          <small className="text-muted"> ( {this.props.project.id} )</small>
        </React.Fragment>
      )
    } else {
      return(
        <span className="text-danger">No information found.</span>
      )
    }
  }

  render() {
    return(
      <div className="details">
        <p>Details for
          <b> {this.props.project.searchValue}</b>:
        </p>

        <table className="table datatable">
          <tbody>
            <tr>
              <th>Project Name:</th>
              <td>
                {this.projectInfo()}
              </td>
            </tr>
            <tr>
              <th>Project Domain:</th>
              <td>
                {this.props.domain.isFetching &&
                  <span className="spinner" />
                }
                {
                  this.props.domain.error &&
                  <span className="text-danger">{this.props.domain.error.error}</span>
                }
                {
                  this.props.domain.data &&
                  <React.Fragment>
                    {this.props.domain.data.name}
                    <small className="text-muted"> ( {this.props.domain.data.id} )</small>
                  </React.Fragment>
                }
              </td>
            </tr>
            <tr>
              <th>Parents:</th>
              <td>
                {this.props.parents.isFetching &&
                  <span className="spinner" />
                }
                {
                  this.props.parents.error &&
                  <span className="text-danger">{this.props.parents.error.error}</span>
                }
                {
                  this.props.parents.data &&
                  <Parents parents={this.props.parents.data} />
                }
              </td>
            </tr>
            <tr>
              <th>Users:</th>
              <td>
                {this.props.users.isFetching &&
                  <span className="spinner" />
                }
                {
                  this.props.users.error &&
                  <span className="text-danger">{this.props.users.error.error}</span>
                }
                {
                  this.props.users.data &&
                  <Users users={this.props.users.data} />
                }
              </td>
            </tr>
            <tr>
              <th>Groups:</th>
              <td>
                {this.props.groups.isFetching &&
                  <span className="spinner" />
                }
                {
                  this.props.groups.error &&
                  <span className="text-danger">{this.props.groups.error.error}</span>
                }
                {
                  this.props.groups.data &&
                  <Groups groups={this.props.groups.data} />
                }
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }
}


export default ProjectDetails;
