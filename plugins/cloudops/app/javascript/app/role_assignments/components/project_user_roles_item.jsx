import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import { Highlighter } from 'react-bootstrap-typeahead';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const removeMemberTooltip = (
  <Tooltip id="removeMemberTooltip">
    This will remove user from project role assignments.
  </Tooltip>
);

// This class renders project user role assignments
export default class ProjectUserRoles extends React.Component {
  state = {
    editMode: false, //used for the switch between view and edit modes
    newUserRoles: {} //stores the edited version of user roles
  }

  // This method sorts roles by name
  sortRoles = (roles) =>
    roles.sort((r1,r2) => {
      if(r1.name < r2.name) return -1
      if(r1.name > r2.name) return 1
      return 0
    })

  // This method renders the project user role assignments view
  renderUserRoles = () => {
    const userRoles = this.sortRoles(this.props.item.roles)

    const count = userRoles.length
    // show role names with descriptions comma separated in a row
    return userRoles.map((role, index) => {
      return (
        <span key={index}>
          <strong>{role.name}</strong>
          {role.description && ' ('+role.description.replace(/(.+)\s+\(.+\)/,"$1")+')'}
          {index < count-1 && ', ' /* add comma unless last item */}
        </span>
      )
    })
  }

  // This method renders the edit view for project user role assignments
  renderEditView = () => {
    // sort available roles by name
    const availableRoles = this.sortRoles(this.props.availableRoles.items)
    // create a map of current user roles: role id => role
    const oldUserRoles = {}
    for(let role of this.props.item.roles) oldUserRoles[role.id] = true

    // create list items
    const lis = availableRoles.map((role,index) => {
      const checked = this.state.newUserRoles[role.id] ? true : false
      const isNew = (checked && !oldUserRoles[role.id])
      const removed = (!checked && oldUserRoles[role.id])
      const roleDescription = role.description ? '('+role.description.replace(/(.+)\s+\(.+\)/,"$1")+')' : ''

      return(
        <li key={index} className='fancy-nav-header'>
          <label className={isNew ? 'bg-info' : ''}>
            <input
              type="checkbox"
              checked={checked}
              value={role.id}
              onChange={(e) => this.updateUserRole(e.target.value, e.target.checked)}/>
            &nbsp;
            <span key={index}>
              {removed ?
                <s><strong>{role.name}</strong> {roleDescription}</s>
                :
                <React.Fragment>
                  <strong>{role.name}</strong> {roleDescription}
                </React.Fragment>
              }

            </span>
          </label>
        </li>
      )
    })

    return <div className='role-assignments'><ul role="menu">{lis}</ul></div>
  }

  // This method updates the state of newUserRoles
  updateUserRole = (roleId, checked) => {
    let newUserRoles = {...this.state.newUserRoles}
    if(newUserRoles[roleId]) {
      delete(newUserRoles[roleId])
    } else {
      const newRole = this.props.availableRoles.items.find((r) => r.id == roleId)
      newUserRoles[roleId] = newRole
    }
    this.setState({newUserRoles})
  }

  hasChanged = () => {
    const oldRoles = this.props.item.roles.map((r) => r.id).sort().join('')
    const newRoles = Object.keys(this.state.newUserRoles).sort().join('')

    return oldRoles != newRoles
  }

  // Called by save button
  saveChanges = () =>
    this.setState({editMode: false})

  // Leave edit mode
  cancelEdit = () =>
    this.setState({editMode: false, newUserRoles: {}})

  // enter edit mode
  showEditView = () => {
    const newUserRoles = {}
    for(let role of this.props.item.roles) newUserRoles[role.id] = role
    // save current user roles in the state, change edit mode and trigger
    // the loadRoles method to get all available roles
    this.setState({editMode: true, newUserRoles}, this.props.loadRolesOnce)
  }

  selectAdminRoles = () => {
    const newUserRoles = {}
    for(let role of this.props.availableRoles.items) {
      if(role.name.indexOf('cloud')<0) newUserRoles[role.id] = role
    }
    this.setState({newUserRoles})
  }

  selectAllRoles = () => {
    const newUserRoles = {}
    for(let role of this.props.availableRoles.items) {
      newUserRoles[role.id] = role
    }
    this.setState({newUserRoles})
  }

  removeAllRoles = () => {
    this.setState({newUserRoles: {}})
  }

  render() {
    const item = this.props.item
    const searchTerm = this.props.searchTerm || ''
    const hasChanged = this.hasChanged()
    const isEmpty = Object.keys(this.state.newUserRoles).length==0
    const isFetching = (!this.props.availableRoles || this.props.availableRoles.isFetching)

    return(
      <tr>
        <td className='user-name-cell'>
          {/*user name*/}
          <Highlighter search={searchTerm}>
            {item.user.description ?
              `${item.user.description} (${item.user.name})`
              :
              item.user.name
            }
          </Highlighter>
          <br/>
          <span className='info-text'>
            <Highlighter search={searchTerm}>{item.user.id}</Highlighter>
          </span>
        </td>

        {this.state.editMode ? //edit mode
          <td colSpan={2}>
            <div className="toolbar toolbar-aligntop">
              { isFetching ?
                <React.Fragment>
                  <span className='spinner'/>Loading ...
                </React.Fragment>
                :
                <React.Fragment>
                  <button
                    className='btn btn-default btn-sm'
                    onClick={this.selectAllRoles}>
                    Select All
                  </button>
                  <button
                    className='btn btn-default btn-sm'
                    onClick={this.selectAdminRoles}>
                    Select Admin Roles
                  </button>
                  <button
                    className='btn btn-default btn-sm hover-danger'
                    onClick={this.removeAllRoles}>
                    Remove All
                  </button>
                </React.Fragment>
              }
              <div className="main-buttons">
                <button className='btn btn-default btn-sm' onClick={this.cancelEdit}>
                  Cancel
                </button>
                { !isFetching &&
                  isEmpty ?
                  <OverlayTrigger placement="top" overlay={removeMemberTooltip}>
                    <button
                      className='btn btn-danger btn-sm'
                      onClick={this.saveChanges}>
                      Remove Member
                    </button>
                  </OverlayTrigger>
                  :
                  <button
                    className='btn btn-primary btn-sm'
                    onClick={this.saveChanges}
                    disabled={!hasChanged}>
                    Save
                  </button>
                }
              </div>
            </div>
            { !isFetching && this.renderEditView()}
          </td>
          : // view mode
          <React.Fragment>
            <td>
              {this.renderUserRoles()}
            </td>
            <td>
              <button
                onClick={this.showEditView}
                className='btn btn-default'>
                Edit
              </button>
            </td>
          </React.Fragment>
        }
      </tr>
    )
  }
}
