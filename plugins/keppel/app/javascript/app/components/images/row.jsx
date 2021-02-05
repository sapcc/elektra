import moment from 'moment';

import { addSuccess } from 'lib/flashes';
import { byteToHuman } from 'lib/tools/size_formatter';

import Digest from '../digest';
import { makeGCNotice, mergeLastPulledAt } from '../utils';

const mediaTypeDescs = {
  'application/vnd.docker.distribution.manifest.v1+prettyjws': 'Docker image (old format)',
  'application/vnd.docker.distribution.manifest.v2+json':      'Docker image',
  'application/vnd.docker.distribution.manifest.list.v2+json': 'Docker image index',
  'application/vnd.oci.image.manifest.v1+json':                'OCI image',
  'application/vnd.oci.image.index.v1+json':                   'OCI image index',
};

export default class ImageRow extends React.Component {
  state = {
    isDeleting: false,
  };

  handleDelete(e) {
    e.preventDefault();
    if (this.state.isDeleting) {
      return;
    }

    const { name: tagName, digest } = this.props.data;

    this.setState({ ...this.state, isDeleting: true });
    this.props.deleteManifest(digest, tagName)
      .then(() => addSuccess(makeGCNotice('Image')))
      .finally(() => this.setState({ ...this.state, isDeleting: false }));
  }

  render() {
    //NOTE: `tagName == null` for untagged image, `tagName != null` for tagged image
    const {
      name: tagName,
      digest,
      media_type: mediaType,
      size_bytes: sizeBytes,
      pushed_at: pushedAtUnix,
      last_pulled_at: lastPulledAtUnix,
      vulnerability_status: vulnerabilityStatus,
    } = this.props.data;

    const pushedAt = moment.unix(pushedAtUnix);
    const lastPulledAt = lastPulledAtUnix ? moment.unix(lastPulledAtUnix) : null;

    return (
      <tr>
        <td className='col-md-4'>
          {tagName ? (
            <React.Fragment>
              <div>{tagName}</div>
              <div className='small text-muted'><Digest digest={digest} /></div>
            </React.Fragment>
          ) : (
            <Digest digest={digest} />
          )}
        </td>
        <td className='col-md-2'>
          <span title={mediaType}>{mediaTypeDescs[mediaType] || mediaType}</span>
        </td>
        <td className='col-md-2'>
          <span title={pushedAt.format('LLLL')}>{pushedAt.fromNow(true)} ago</span>
        </td>
        <td className='col-md-2'>
          {lastPulledAt ? (
            <span title={lastPulledAt.format('LLLL')}>{lastPulledAt.fromNow(true)} ago</span>
          ) : (
            <span className='text-muted'>Never</span>
          )}
        </td>
        <td className='col-md-1'>
          {byteToHuman(sizeBytes)}
        </td>
        <td className='col-md-1'>
          {vulnerabilityStatus}
        </td>
        {this.props.canEdit && (
          <td className='snug text-right text-nobreak'>
            {this.state.isDeleting ? (
              <React.Fragment>
                <span className='spinner' /> Deleting...
              </React.Fragment>
            ) : (
              <div className='btn-group'>
                <button
                  className='btn btn-default btn-sm dropdown-toggle'
                  disabled={false}
                  type="button"
                  data-toggle="dropdown"
                  aria-expanded={true}>
                  <span className="fa fa-cog"></span>
                </button>
                <ul className="dropdown-menu dropdown-menu-right" role="menu">
                  <li><a href="#" onClick={e => this.handleDelete(e)}>Delete</a></li>
                </ul>
              </div>
            )}
          </td>
        )}
      </tr>
    );
  }
}
