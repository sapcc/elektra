import Parents from './parents';
import Users from './users';

class ProjectDetails extends React.Component {
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
                {this.props.project.name}
                <small className="text-muted"> ( {this.props.project.id} )</small>
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
                  <Users users={this.props.users.data.users} />
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
