import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import ProjectUserRolesItem from './project_user_roles_item';
import { regexString } from 'lib/tools/regex_string';
import { AutocompleteField } from 'lib/components/autocomplete_field';
import ProjectUserRolesInlineEdit from '../containers/project_user_roles_edit_form';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const isMemberTooltip = (
  <Tooltip id="removeMemberTooltip">
    This user is already a member of this project!
  </Tooltip>
);


export default class ProjectUserRoles extends React.Component {
  state = {
    filterString: null,
    showNewMemberForm: false,
    newMember: null,
    showNewMemberInput: false
  }

  componentDidMount() {
    this.props.loadProjectRoles(this.props.project.id)
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

  handleNewMember = (user) => {
    if(Array.isArray(user)) user = user[0]

    if(!user) return this.setState({newMember: null})

    if(user.constructor == String) {
      if(user.trim().length==0) {
        this.setState({newMember: null})
      } else {
        this.setState({newMember: {id: user}})
      }
    } else if(user.constructor == Object) {
      this.setState({newMember: {id: user.id, name: user.name, description: user.full_name}})
    } else this.setState({newMember: null})
  }

  resetNewMemberState = () => {
    this.setState({showNewMemberForm: false, showNewMemberInput: false, newMember: null})
  }

  alreadyMember = () => {
    if(!this.props.projectUserRoles || this.props.projectUserRoles.items.length==0) {
      return false
    }
    const item = this.props.projectUserRoles.items.find((i) =>
      i && i.user.id == this.state.newMember.id
    )
    return item ? true : false
  }

  render() {
    const items = this.filterRoleAssignments()
    const isMember = this.state.newMember && this.alreadyMember()
    return (
      <React.Fragment>
        <div className="toolbar">
          {!this.state.showNewMemberInput && items.length>0 &&
            <React.Fragment>
              <SearchField
                onChange={(term) => this.setState({filterString: term})}
                placeholder='Name, C/D/I-number, or ID'
                isFetching={false}
                searchIcon={true}
                text='Filter users by name or id'
              />
              <span className="toolbar-input-divider"></span>
          </React.Fragment>
          }

          {(!this.props.projectUserRoles || this.props.projectUserRoles.isFetching) &&
            <div className="toolbar-container"><span className='spinner'></span>Loading ...</div>
          }

          <div className='main-buttons'>
            {this.state.showNewMemberInput ?
              <div className="input-group input-group-left-button">
                <span className="input-group-btn">
                  <button
                    className='btn btn-default'
                    onClick={() => this.setState({showNewMemberInput: false})}>
                    x
                  </button>
                </span>
                <AutocompleteField
                  type='users'
                  domainId={this.props.project.domain_id}
                  onSelected={this.handleNewMember}
                  onInputChange={this.handleNewMember}/>
                <span className="input-group-btn">
                  <button
                    className='btn btn-primary'
                    disabled={isMember || !this.state.newMember}
                    onClick={() => this.setState({showNewMemberForm: true})}>
                      {isMember ?
                        <OverlayTrigger placement="top" overlay={isMemberTooltip}>
                          <span>Add</span>
                        </OverlayTrigger>
                        :
                        <span>Add</span>
                      }
                  </button>
                </span>
              </div>
              :
              <button
                className='btn btn-primary'
                onClick={() => this.setState({showNewMemberInput: true})}>
                Add New Member
              </button>
            }
          </div>
        </div>

        { (items.length > 0 || this.state.showNewMemberForm) &&
          <table className="table">
            <thead>
              <tr>
                <th>User</th>
                <th>Roles</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {this.state.showNewMemberForm &&
                <tr>
                  <td className='user-name-cell'>
                    {this.state.newMember &&
                      <React.Fragment>
                        {this.state.newMember.description ?
                          `${this.state.newMember.description} (${this.state.newMember.name})`
                          :
                          this.state.newMember.name
                        }
                        <br/>
                        <span className='info-text'>
                          {this.state.newMember.id}
                        </span>
                      </React.Fragment>
                    }
                  </td>

                  <td colSpan={2}>
                    {this.state.newMember &&
                      <ProjectUserRolesInlineEdit
                        projectId={this.props.project.id}
                        userId={this.state.newMember.id}
                        userRoles={[]}
                        onSave={this.resetNewMemberState}
                        onCancel={this.resetNewMemberState}/>
                    }
                  </td>
                </tr>
              }
              {
                items.map((item,index) =>
                  <ProjectUserRolesItem
                    item={item}
                    key={index}
                    projectId={this.props.project.id}
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
