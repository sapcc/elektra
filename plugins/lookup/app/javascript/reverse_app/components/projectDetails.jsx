import Parents from './parents';

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
              <th>Project Domain:</th>
              <td>{}</td>
            </tr>
            <tr>
              <th>Project Name:</th>
              <td>{this.props.project.name}</td>
            </tr>
            <tr>
              <th>Project ID:</th>
              <td>{this.props.project.id}</td>
            </tr>
            <tr>
              <th>Parents:</th>
              <td>
                <Parents parents={this.props.project.parents} />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }
}


export default ProjectDetails;
