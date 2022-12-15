import React from "react"
import GroupMembers from "./groupMembers"

class Groups extends React.Component {
  state = {
    membersListShown: {},
  }

  handleMembersList = (groupId, state) => {
    const membersListShown = { ...this.state.membersListShown }
    membersListShown[groupId] = state
    this.setState({ membersListShown })
  }

  fetchGroupMembers = (groupId) => {
    if (!this.props.groupMembers[groupId]) {
      this.props.fetchGroupMembers(groupId)
    }
  }

  toggleMembersShow = (event, groupId) => {
    // eslint-disable-next-line no-undef
    var li = $(event.target.closest("li"))
    if (li.hasClass("node-expanded")) {
      li.removeClass("node-expanded")
      this.handleMembersList(groupId, false)
    } else {
      li.addClass("node-expanded")
      this.handleMembersList(groupId, true)
      this.fetchGroupMembers(groupId)
    }
  }

  render() {
    const { groups, groupMembers } = this.props
    return (
      <ul className="tree tree-expandable">
        {Object.keys(this.props.groups).map((key) => (
          <li key={key} className="has-children">
            <i
              className="node-icon"
              onClick={(e) => this.toggleMembersShow(e, groups[key]["id"])}
            ></i>
            <span>
              {groups[key]["name"]}
              <small className="text-muted"> ( {groups[key]["id"]} )</small>
              {groupMembers[groups[key]["id"]] &&
                this.state.membersListShown[groups[key]["id"]] && (
                  <GroupMembers members={groupMembers[groups[key]["id"]]} />
                )}
            </span>
          </li>
        ))}
      </ul>
    )
  }
}

export default Groups
