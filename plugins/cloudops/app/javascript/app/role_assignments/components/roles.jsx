import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';

export default class RoleAssignments extends React.Component {
  componentDidMount() {
    this.props.loadRoles(this.props.project.id)
  }

  render() {
    console.log('roles',this.props.roles)
    return (
      <React.Fragment>
        <div className="toolbar">
          <SearchField
            onChange={(user) => console.log('Filter by user')}
            placeholder='Name, C/D/I-number, or ID'
            isFetching={false}
            searchIcon={true}
            text='Filter users by name or id'
          />
          <span className="toolbar-input-divider"></span>
        </div>

        { this.props.roles && this.props.roles.items.length > 0 &&
          <table className="table">
            <thead>
              <tr>
                <th>User</th>
                <th>Roles</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {
                this.props.roles.items.map((item,index) =>
                  <tr key={index}>
                    <td>{item.user.description || item.user.name}</td>
                    <td>
                      {item.roles.map((role,index) =>
                        <span key={index}>{role.description || role.name} </span>
                      )}
                    </td>
                    <td></td>
                  </tr>
                )
              }

            </tbody>
          </table>
        }

        {/*<AjaxPaginate
          hasNext={this.props.projects.hasNext}
          isFetching={this.props.projects.isFetching}
          text={`${this.props.projects.items.length}/${this.props.projects.total}`}
          onLoadNext={() => this.props.loadNext({domain: this.state.domain, project: this.state.project})}/>
        */}
      </React.Fragment>
    )
  }
}
