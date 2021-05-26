import { Modal, Button } from "react-bootstrap"
import { Link } from "react-router-dom"

const Row = ({ label, value, children }) => {
  return (
    <tr>
      <th style={{ width: "30%" }}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
}

export default class ShowReplica extends React.Component {
  constructor(props) {
    super(props)
    this.state = { show: true }
    this.close = this.close.bind(this)
  }

  close(e) {
    if (e) e.stopPropagation()
    this.setState({ show: false })
    setTimeout(() => this.props.history.replace("/replicas"), 300)
  }

  render() {
    let { replica } = this.props

    return (
      <Modal
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Show Replica {replica && replica.name}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          {!replica ? (
            <div>
              <span className="spinner" />
              Loading...
            </div>
          ) : (
            <table className="table no-borders">
              <tbody>
                <Row label="ID" value={replica.id} />
                <Row label="Status" value={replica.status} />
                <Row label="Replica State" value={replica.replica_state} />
                <Row label="Share ID">
                  <Link to={`/shares/${replica.share_id}/show`}>
                    {replica.share_id}
                  </Link>
                </Row>
                <Row
                  label="Share Network ID"
                  value={replica.share_network_id}
                />
                <Row label="Share Server ID" value={replica.share_server_id} />
                <Row label="Created At" value={replica.created_at} />
              </tbody>
            </table>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
