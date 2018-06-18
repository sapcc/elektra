import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import { Highlighter } from 'react-bootstrap-typeahead';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import makeCancelable from 'lib/tools/cancelable_promise';

const removeMemberTooltip = (type) => (
  <Tooltip id="removeMemberTooltip">
    {`This will remove ${type} from project role assignments.`}
  </Tooltip>
);

// This class renders edit form for project role assignments
export default class ProjectRoleAssignmentsInlineForm extends React.Component {
  state = {
    currentMemberRoleIDs: [], //stores current member roles
    newMemberRoleIDs: [], //stores the edited version of member roles
    availableRoles: [],
    saving: false,
    errors: null
  }

  componentDidMount() {
    const currentMemberRoleIDs = this.props.memberRoles.map((r) => r.id)

    const newState = {
      currentMemberRoleIDs,
      newMemberRoleIDs: currentMemberRoleIDs,
    }

    if(this.props.availableRoles) {
      newState['availableRoles'] = this.sortRoles(this.props.availableRoles.items)
    }
    // save current member roles in the state, change edit mode and trigger
    // the loadRoles method to get all available roles
    this.setState(newState, this.props.loadRolesOnce)
  }

  componentWillUnmount() {
    // cancel submit promis if already created
    if(this.submitPromise) this.submitPromise.cancel();
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

  // This method renders the edit view for project member role assignments
  renderEditView = () => {
    // create list items
    const lis = this.state.availableRoles.map((role,index) => {
      const checked = this.state.newMemberRoleIDs.indexOf(role.id)>=0
      const isNew = (checked && this.state.currentMemberRoleIDs.indexOf(role.id)<0)
      const removed = (!checked && this.state.currentMemberRoleIDs.indexOf(role.id)>=0)
      const roleDescription = role.description ? '('+role.description.replace(/(.+)\s+\(.+\)/,"$1")+')' : ''
      let labelClassName = ''
      if (isNew) {
        labelClassName = 'bg-info'
      }
      if (removed) {
        labelClassName = 'u-text-remove-highlight'
      }

      return(
        <li key={index}>
          <label className={labelClassName}>
            <input
              type="checkbox"
              checked={checked}
              value={role.id}
              onChange={(e) => this.updateMemberRole(e.target.value, e.target.checked)}/>
            &nbsp;
            <span key={index}>
              <React.Fragment>
                <strong>{role.name}</strong> {roleDescription}
              </React.Fragment>
            </span>
          </label>
        </li>
      )
    })

    return <div className='role-assignments'><ul role="menu">{lis}</ul></div>
  }

  // This method updates the state of newUserRoles
  updateMemberRole = (roleId, checked) => {
    const index = this.state.newMemberRoleIDs.indexOf(roleId)

    if( (index>=0 && checked) || (index<0 && !checked)) return;

    let newMemberRoleIDs = this.state.newMemberRoleIDs.slice()
    if(index>=0 && !checked) newMemberRoleIDs.splice(index,1)
    if(index<0 && checked) newMemberRoleIDs.push(roleId)

    this.setState({newMemberRoleIDs})
  }

  hasChanged = () => {
    const oldRoles = this.state.currentMemberRoleIDs.sort().join('')
    const newRoles = this.state.newMemberRoleIDs.sort().join('')

    return oldRoles != newRoles
  }

  // Called by save button
  saveChanges = () => {
    this.setState({saving: true})

    this.submitPromise = makeCancelable(
      this.props.updateProjectMemberRoleAssignments(
        this.props.projectId,
        this.props.memberId,
        this.state.newMemberRoleIDs
     )
    )

    this.submitPromise
        .promise
        .then(() => {
          this.setState({saving: false, error: null}, this.props.onSave)
        })
        .catch(reason => {
          if (!reason.isCanceled) { // promise is not canceled
            // handle errors
            this.setState({saving: false, errors: reason})
          }
      })
  }

  // Leave edit mode
  cancelEdit = () => this.props.onCancel()

  selectAdminRoles = () => {
    const newMemberRoleIDs = this.state.availableRoles.filter((r) =>
      r.name.indexOf('cloud')<0
    ).map((r) => r.id)
    this.setState({newMemberRoleIDs})
  }

  selectAllRoles = () => {
    this.setState({newMemberRoleIDs: this.state.availableRoles.map((r) => r.id)})
  }

  removeAllRoles = () => {
    this.setState({newMemberRoleIDs: []})
  }

  render() {
    const hasChanged = this.hasChanged()
    const isEmpty = this.state.newMemberRoleIDs.length==0
    const isFetching = (!this.props.availableRoles || this.props.availableRoles.isFetching)

    return(
      <React.Fragment>
        <div className="toolbar toolbar-inline">
          <div className="toolbar-container">
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
          </div>

          <div className="main-buttons">
            <button
              className='btn btn-default btn-sm'
              onClick={this.cancelEdit}
              disabled={this.state.saving}>
              Cancel
            </button>
            { !isFetching &&
              isEmpty ?
              <OverlayTrigger placement="top" overlay={removeMemberTooltip(this.props.memberType)}>
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
        { this.state.errors &&
          <div className='alert alert-error'>{this.state.errors}</div>
        }
        { !isFetching && this.renderEditView()}
      </React.Fragment>
    )
  }
}
