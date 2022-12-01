/* eslint-disable no-undef */
import React from "react"
export default class ImageMemberItem extends React.Component {
  state = {
    confirm: false,
  }

  handleDelete = () => {
    if (this.state.confirm) {
      this.props.handleDelete()
    } else {
      this.setState({ confirm: true })
      setTimeout(() => this.setState({ confirm: false }), 3000)
    }
  }

  render() {
    const canRemoveMember =
      policy.isAllowed("image:member_delete", { image: this.props.image }) &&
      this.props.member.status == "pending" &&
      !this.props.member.isDeleting
    return (
      <tr className={this.props.member.isDeleting && "updating"}>
        <td>
          {this.props.member.target_name}
          <br />
          <span className="info-text">{this.props.member.member_id}</span>
        </td>
        <td>{this.props.member.status}</td>
        <td>
          {canRemoveMember && (
            <button
              className="btn btn-danger btn-sm pull-right"
              onClick={(e) => {
                e.preventDefault()
                this.handleDelete()
              }}
              disabled={this.props.member.isDeleting}
            >
              {this.state.confirm ? "Confirm" : <i className="fa fa-minus" />}
            </button>
          )}
        </td>
      </tr>
    )
  }
}
