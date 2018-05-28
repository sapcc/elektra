import { SearchField } from 'lib/components/search_field';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import { Highlighter } from 'react-bootstrap-typeahead';
import ProjectUserRolesInlineEdit from '../containers/project_user_roles_edit_form';

// This class renders project user role assignments
export default class ProjectUserRolesItem extends React.Component {
  state = {
    editMode: false //used for the switch between view and edit modes
  }

  // This method sorts roles by name
  sortRoles = (roles) =>
    roles.sort((r1,r2) => {
      if(r1.name < r2.name) return -1
      if(r1.name > r2.name) return 1
      return 0
    })

  render() {
    const item = this.props.item
    const searchTerm = this.props.searchTerm || ''
    const userRoles = this.sortRoles(this.props.item.roles)
    const count = userRoles.length

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
            <ProjectUserRolesInlineEdit
              projectId={this.props.projectId}
              userId={this.props.item.user.id}
              userRoles={this.props.item.roles}
              onSave={() => this.setState({editMode: false})}
              onCancel={() => this.setState({editMode: false})}/>
          </td>
          : // view mode
          <React.Fragment>
            <td>
              {  /* show role names with descriptions comma separated in a row */
                 userRoles.map((role, index) =>
                   <span key={index}>
                     <strong>{role.name}</strong>
                     {role.description && ' ('+role.description.replace(/(.+)\s+\(.+\)/,"$1")+')'}
                     {index < count-1 && ', ' /* add comma unless last item */}
                   </span>
                 )
              }
            </td>
            <td>
              <button
                onClick={() => this.setState({editMode: true})}
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
