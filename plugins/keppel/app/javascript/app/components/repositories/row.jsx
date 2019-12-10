import moment from 'moment';
import { Link } from 'react-router-dom';

import { byteToHuman } from 'lib/tools/size_formatter';

export default class RepositoryRow extends React.Component {
  render() {
    const { name: accountName } = this.props.account;
    const {
      name: repoName,
      manifest_count: manifestCount,
      tag_count: tagCount,
      size_bytes: sizeBytes,
      pushed_at: pushedAtUnix,
    } = this.props.repo;
    const pushedAt = moment.unix(pushedAtUnix);

    return (
      <tr>
        <td className='col-md-4'>
          <Link to={`/repo/${accountName}/${repoName}`}>{repoName}</Link>
        </td>
        <td className='col-md-3'>
          {manifestCount == tagCount
            ? `${tagCount} tags`
            : `${tagCount} tags + ${manifestCount - tagCount} untagged images`
          }
        </td>
        <td className='col-md-3'>
          {byteToHuman(sizeBytes)}
        </td>
        <td className='col-md-2'>
          <span title={pushedAt.format('LLLL')}>{pushedAt.fromNow(true)} ago</span>
        </td>
      </tr>
    );
  }
}
