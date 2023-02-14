import { DefeatableLink } from "lib/components/defeatable_link"
import { policy } from "lib/policy"
import { Modal, Button } from "react-bootstrap"
import ErrorMessageItem from "./item"
import React from "react"

export default class ErrorMessageList extends React.Component {
  state = { show: true }

  restoreUrl = (e) => {
    const type = this.props.match && this.props.match.params.type
    if (!this.state.show) this.props.history.replace(type || "shares")
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({ show: false })
  }

  loadDependencies = (props) => props.loadErrorMessagesOnce()

  componentDidMount() {
    this.loadDependencies(this.props)
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  render() {
    let { errorMessages } = this.props

    return (
      <Modal
        show={this.state.show}
        onExited={this.restoreUrl}
        onHide={this.hide}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Error Log</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {!errorMessages || errorMessages.isFetching ? (
            <div>
              <span className="spinner" />
              Loading...
            </div>
          ) : (
            <table className="table error-messages">
              <thead>
                <tr>
                  <th>Level</th>
                  <th>Error</th>
                  <th>Created</th>
                </tr>
              </thead>
              <tbody>
                {errorMessages.items.length == 0 && (
                  <tr>
                    <td colSpan="3">No errors found.</td>
                  </tr>
                )}
                {errorMessages.items.map((errorMessage, index) => (
                  <ErrorMessageItem key={index} errorMessage={errorMessage} />
                ))}
              </tbody>
            </table>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.hide}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
