import { Modal, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';

import { Form } from 'lib/elektra-form';

import Digest from '../digest';

const typeOfManifest = {
  'application/vnd.docker.distribution.manifest.v2+json':      'image',
  'application/vnd.docker.distribution.manifest.list.v2+json': 'list',
  'application/vnd.oci.image.manifest.v1+json':                'image',
  'application/vnd.oci.image.index.v1+json':                   'list',
};

export default class AccountUpstreamConfigModal extends React.Component {
  state = {
    show: true,
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({ ...this.state, show: false });
    setTimeout(() => this.props.history.replace(`/repo/${this.props.account.name}/${this.props.repository.name}`), 300);
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
    if (isFetchingManifests || manifests === undefined) {
      return <p><span className='spinner' /> Loading image list...</p>;
    }
    const { isFetching: isFetchingManifest, data: manifest } = this.props.manifest;
    if (isFetchingManifest || manifest === undefined) {
      return <p><span className='spinner' /> Loading image manifest...</p>;
    }

    const { digest } = this.props.match.params;
    const { media_type: mediaType, tags } = manifests.find(m => m.digest == digest) || {};

    //className='keppel' on <Modal> ensures that CSS rules from this plugin can apply
    return (
      <Modal backdrop='static' className='keppel' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Image details
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <table className='table datatable'>
            <tbody>
              <tr>
                <th>Canonical digest</th>
                <td colSpan='2'><Digest digest={digest} wideDisplay={true} /></td>
              </tr>
              {(tags && tags.length > 0) ? (
                <tr>
                  <th>Tagged as</th>
                  <td colSpan='2'>{tags.map(t => t.name).sort().join(", ")}</td>
                </tr>
              ) : null}
              <tr>
                <th>MIME type</th>
                <td colSpan='2'>{mediaType}</td>
              </tr>
              {typeOfManifest[mediaType] == 'list' ? this.renderSubmanifestReferences(manifest.manifests, manifests) : null}
            </tbody>
          </table>
          {typeOfManifest[mediaType] != 'list' && <pre>{JSON.stringify(this.props, null, 2)}</pre>}
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    );
  }

  renderSubmanifestReferences(submanifests, allManifests) {
    const rows = [];
    let rowIndex = 0;
    for (const manifest of submanifests) {
      rowIndex++;
      const manifestInfo = allManifests.find(m => m.digest == manifest.digest);
      const detailsLink = (
        <Link to={`/repo/${this.props.account.name}/${this.props.repository.name}/-/manifest/${manifest.digest}/details`}>Details</Link>
      );

      rows.push(<tr key={`spacer-${manifest.digest}`} className='spacer'><td /></tr>);

      rows.push(
        <tr key={`digest-${manifest.digest}`}>
          <th rowSpan={manifestInfo ? 4 : 3}>Payload #{rowIndex}</th>
          <td colSpan='3'><Digest digest={manifest.digest} wideDisplay={true} /></td>
        </tr>
      );

      rows.push(
        <tr key={`status-${manifest.digest}`}>
          <th>Status</th>
          <td>{manifestInfo ? <React.Fragment>Available ({detailsLink})</React.Fragment> : 'Not available'}</td>
        </tr>
      );

      if (manifestInfo) {
        rows.push(
          <tr key={`vulnstatus-${manifest.digest}`}>
            <th>Vulnerability status</th>
            <td>{manifestInfo.vulnerability_status} ({detailsLink})</td>
          </tr>
        );
      }

      rows.push(
        <tr key={`platform-${manifest.digest}`}>
          <th>Platform</th>
          <td><code>{JSON.stringify(manifest.platform)}</code></td>
        </tr>
      );
    }
    return <React.Fragment>{rows}</React.Fragment>;
  }
}
