import moment from 'moment';

import { byteToHuman } from 'lib/tools/size_formatter';

const mediaTypeDescs = {
  'application/vnd.docker.distribution.manifest.v1+prettyjws': 'Docker image (old format)',
  'application/vnd.docker.distribution.manifest.v2+json':      'Docker image',
  'application/vnd.docker.distribution.manifest.list.v2+json': 'Docker image index',
  'application/vnd.oci.image.manifest.v1+json':                'OCI image',
  'application/vnd.oci.image.index.v1+json':                   'OCI image index',
};

export default class ManifestRow extends React.Component {
  render() {
    //NOTE: `tagName == null` for untagged manifest, `tagName != null` for tag
    const { name: tagName, digest, media_type: mediaType, size_bytes: sizeBytes, pushed_at: pushedAtUnix } = this.props.data;
    const pushedAt = moment.unix(pushedAtUnix);

    return (
      <tr>
        <td className='col-md-6'>
          {tagName ? (
            <React.Fragment>
              <div>{tagName}</div>
              <div className='small text-muted'>{digest}</div>
            </React.Fragment>
          ) : (
            digest
          )}
        </td>
        <td className='col-md-2'>
          <span title={mediaType}>{mediaTypeDescs[mediaType] || mediaType}</span>
        </td>
        <td className='col-md-2'>
          {byteToHuman(sizeBytes)}
        </td>
        <td className='col-md-2'>
          <span title={pushedAt.format('LLLL')}>{pushedAt.fromNow(true)} ago</span>
        </td>
      </tr>
    );
  }
}
