import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

export default class AccountUpstreamConfigModal extends React.Component {
  state = {
    show: true,
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({ ...this.state, show: false });
    setTimeout(() => this.props.history.replace(`/repo/${this.props.accountName}/${this.props.repoName}`), 300);
  }

  componentDidMount() {
    this.loadData();
  }
  componentDidUpdate() {
    this.loadData();
  }
  loadData() {
    const { name: accountName } = this.props.account || {};
    const { name: repoName } = this.props.repository || {};
    if (accountName && repoName) {
      this.props.loadManifestsOnce();
      this.props.loadManifestOnce();
    }
  }

  render() {
    const { isFetching: isFetchingManifests, data: manifests } = this.props.manifests;
    if (isFetchingManifests) {
      return <p><span className='spinner' /> Loading image list...</p>;
    }
    const { isFetching: isFetchingManifest, data: manifest } = this.props.manifest;
    if (isFetchingManifest) {
      return <p><span className='spinner' /> Loading image manifest...</p>;
    }

    const { digest } = this.props.match.params;

    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Image {digest}
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <pre>{JSON.stringify(this.props, null, 2)}</pre>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
