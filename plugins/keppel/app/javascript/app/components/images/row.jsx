import moment from 'moment';

import { byteToHuman } from 'lib/tools/size_formatter';

import Digest from '../digest';

const mediaTypeDescs = {
  'application/vnd.docker.distribution.manifest.v1+prettyjws': 'Docker image (old format)',
  'application/vnd.docker.distribution.manifest.v2+json':      'Docker image',
  'application/vnd.docker.distribution.manifest.list.v2+json': 'Docker image index',
  'application/vnd.oci.image.manifest.v1+json':                'OCI image',
  'application/vnd.oci.image.index.v1+json':                   'OCI image index',
};

export default class ImageRow extends React.Component {
  render() {
    //NOTE: `tagName == null` for untagged image, `tagName != null` for tagged image
    const { name: tagName, digest, media_type: mediaType, size_bytes: sizeBytes, pushed_at: pushedAtUnix } = this.props.data;
    const pushedAt = moment.unix(pushedAtUnix);

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
        <td className='col-md-3'>
          <span title={mediaType}>{mediaTypeDescs[mediaType] || mediaType}</span>
        </td>
        <td className='col-md-2'>
          {byteToHuman(sizeBytes)}
        </td>
        <td className='col-md-3'>
          <span title={pushedAt.format('LLLL')}>{pushedAt.fromNow(true)} ago</span>
        </td>
      </tr>
    );
  }
}
