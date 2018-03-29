import GroupMembers from './groupMembers';

class Groups extends React.Component {

  fetchGroupMembers = (groupId) => {
    this.props.fetchGroupMembers(groupId)
  }

  render() {
    return(
      <ul className="plain-list plain-list-widespaced">
        {Object.keys(this.props.groups).map(key => (
          <li key={key}>
            {this.props.groups[key]['name']}
            <small className="text-muted"> ( {this.props.groups[key]['id']} )</small>
            <button
              className="btn btn-primary"
              onClick={(e)=>this.fetchGroupMembers(this.props.groups[key]['id'])}>
              Test
            </button>
            {this.props.groupMembers[this.props.groups[key]['id']] &&
              <GroupMembers members={this.props.groupMembers[this.props.groups[key]['id']]}/>
            }
          </li>
        ))}
      </ul>
    )
  }
}

export default Groups;
