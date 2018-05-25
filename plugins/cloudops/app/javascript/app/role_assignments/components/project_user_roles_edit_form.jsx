import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import { Highlighter } from 'react-bootstrap-typeahead';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const removeMemberTooltip = (
  <Tooltip id="removeMemberTooltip">
    This will remove user from project role assignments.
  </Tooltip>
);

// This class renders edit form for project user role assignments
export default class ProjectUserRolesInlineEdit extends React.Component {
  state = {
    currentUserRoleIDs: [], //stores current user roles
    newUserRoleIDs: [], //stores the edited version of user roles
    availableRoles: [],
    saving: false,
    error: null
  }

  componentDidMount() {
    const currentUserRoleIDs = this.props.userRoles.map((r) => r.id)

    const newState = {
      currentUserRoleIDs,
      newUserRoleIDs: currentUserRoleIDs,
    }

    if(this.props.availableRoles) {
      newState['availableRoles'] = this.sortRoles(this.props.availableRoles.items)
    }
    // save current user roles in the state, change edit mode and trigger
    // the loadRoles method to get all available roles
    this.setState(newState, this.props.loadRolesOnce)
  }

  componentWillReceiveProps(nextProps) {
    if(this.state.availableRoles.length==0 && nextProps.availableRoles) {
      this.setState({availableRoles: this.sortRoles(nextProps.availableRoles.items)})
    }
  }

  // This method sorts roles by name
  sortRoles = (roles) =>
    roles.sort((r1,r2) => {
      if(r1.name < r2.name) return -1
      if(r1.name > r2.name) return 1
      return 0
    })

  // This method renders the edit view for project user role assignments
  renderEditView = () => {
    // create list items
    const lis = this.state.availableRoles.map((role,index) => {
      const checked = this.state.newUserRoleIDs.indexOf(role.id)>=0
      const isNew = (checked && this.state.currentUserRoleIDs.indexOf(role.id)<0)
      const removed = (!checked && this.state.currentUserRoleIDs.indexOf(role.id)>=0)
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
    const index = this.state.newUserRoleIDs.indexOf(roleId)

    if( (index>=0 && checked) || (index<0 && !checked)) return;

    let newUserRoleIDs = this.state.newUserRoleIDs.slice()
    if(index>=0 && !checked) newUserRoleIDs.splice(index,1)
    if(index<0 && checked) newUserRoleIDs.push(roleId)

    this.setState({newUserRoleIDs})
  }

  hasChanged = () => {
    const oldRoles = this.state.currentUserRoleIDs.sort().join('')
    const newRoles = this.state.newUserRoleIDs.sort().join('')

    return oldRoles != newRoles
  }

  // Called by save button
  saveChanges = () => {
    this.setState({saving: true})
    this.props.updateProjectUserRoles(
      this.props.projectId,
      this.props.userId,
      this.state.newUserRoleIDs
    ).then(() => this.setState({saving: false, error: null}, this.props.onSave))
     .catch((error) => {
       this.setState({saving: false, error: error})
     })
  }

  // Leave edit mode
  cancelEdit = () => this.props.onCancel()

  selectAdminRoles = () => {
    const newUserRoleIDs = this.state.availableRoles.filter((r) =>
      r.name.indexOf('cloud')<0
    ).map((r) => r.id)
    this.setState({newUserRoleIDs})
  }

  selectAllRoles = () => {
    this.setState({newUserRoleIDs: this.state.availableRoles.map((r) => r.id)})
  }

  removeAllRoles = () => {
    this.setState({newUserRoleIDs: []})
  }

  render() {
    const hasChanged = this.hasChanged()
    const isEmpty = this.state.newUserRoleIDs.length==0
    const isFetching = (!this.props.availableRoles || this.props.availableRoles.isFetching)

    return(
      <React.Fragment>
        <div className="toolbar toolbar-aligntop">
          { isFetching ?
            <React.Fragment>
              <span className='spinner'/>Loading ...
            </React.Fragment>
            :
            <React.Fragment>
              <button
                className='btn btn-default btn-sm'
                onClick={this.selectAllRoles}
                disabled={this.state.saving}>
                Select All
              </button>
              <button
                className='btn btn-default btn-sm'
                onClick={this.selectAdminRoles}
                disabled={this.state.saving}>
                Select Admin Roles
              </button>
              <button
                className='btn btn-default btn-sm hover-danger'
                onClick={this.removeAllRoles}
                disabled={this.state.saving}>
                Remove All
              </button>
            </React.Fragment>
          }
          <div className="main-buttons">
            <button
              className='btn btn-default btn-sm'
              onClick={this.cancelEdit}
              disabled={this.state.saving}>
              Cancel
            </button>
            { !isFetching &&
              isEmpty ?
              <OverlayTrigger placement="top" overlay={removeMemberTooltip}>
                <button
                  className='btn btn-danger btn-sm'
                  disabled={this.state.saving}
                  onClick={this.saveChanges}>
                  { this.state.saving ? 'Please Wait ...'  : 'Remove Member'}
                </button>
              </OverlayTrigger>
              :
              <button
                className='btn btn-primary btn-sm'
                onClick={this.saveChanges}
                disabled={!hasChanged || this.state.saving}>
                { this.state.saving ? 'Please Wait ...'  : 'Save'}
              </button>
            }
          </div>
        </div>
        { this.state.error &&
          <div className='text-danger'>{this.state.error}</div>
        }
        { !isFetching && this.renderEditView()}
      </React.Fragment>
    )
  }
}
