import React from "react"

const display = (msg) => (
  <>
    <span className="spinner" /> {msg}...
  </>
)

export default class AccountDeleter extends React.Component {

  componentDidMount() {
    this.tryDelete()
  }

  tryDelete() {
    this.props
      .deleteAccount(this.props.accountName)
      .then((response) => this.props.handleDoneDeleting(response))
      .catch(() => this.props.handleDoneDeleting(false))
  }

  render() {
    return display("Deletion in progress.")
  }
}
