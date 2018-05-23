import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import ProjectUserRolesItem from './project_user_roles_item';
import { regexString } from 'lib/tools/regex_string';

export default class ProjectUserRoles extends React.Component {
  state = { filterString: null }

  componentDidMount() {
    this.props.loadProjectUserRoles(this.props.project.id)
  }

  filterRoleAssignments = () => {
    if(!this.props.projectUserRoles) return []

    if(!this.state.filterString || this.state.filterString.trim().length==0) {
      return this.props.projectUserRoles.items
    }

    const regex = new RegExp(regexString(this.state.filterString.trim()), "i");
    return this.props.projectUserRoles.items.filter((role) =>
      `${role.user.name} ${role.user.description} ${role.user.id}`.match(regex)
    )
  }

  render() {
    const items = this.filterRoleAssignments()
    return (
      <React.Fragment>
        <div className="toolbar">
          <SearchField
            onChange={(term) => this.setState({filterString: term})}
            placeholder='Name, C/D/I-number, or ID'
            isFetching={false}
            searchIcon={true}
            text='Filter users by name or id'
          />
          <span className="toolbar-input-divider"></span>
        </div>

        { items.length > 0 &&
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
                items.map((item,index) =>
                  <ProjectUserRolesItem
                    item={item}
                    key={index}
                    availableRoles={this.props.roles}
                    loadRolesOnce={this.props.loadRolesOnce}
                    searchTerm={this.state.filterString} />
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
