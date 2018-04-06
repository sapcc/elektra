import Parents from './parents';
import Users from './users';
import Groups from '../containers/groups';

class ProjectDetails extends React.Component {

  detailsText = () => {
    var detailsText = '';
    const {searchBy, searchTypes, searchValue} = this.props.project
    var filteredTypes = {... searchTypes}
    delete filteredTypes[searchBy]
    const searchKeys = Object.keys(filteredTypes)
    searchKeys.map( (key, i) => {
      detailsText = detailsText + filteredTypes[key]
      if (i < searchKeys.length - 2) {
        detailsText = detailsText + ','
      } else if (i < searchKeys.length - 1) {
        detailsText = detailsText + ' and '
      }
    })
    return (
      <React.Fragment>
        Searched by <b>{searchBy}</b>. Details for <b>{searchValue}</b>:
        <br/><small>(It didn't complain the constraints for {detailsText})</small>
      </React.Fragment>
    )
  }

  render() {
    return(
      <div className="searchResults">
        <p>{this.detailsText()}</p>
        <table className="table">
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
              <th>Admin Users:</th>
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
