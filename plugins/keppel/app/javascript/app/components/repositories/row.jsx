import { Link } from 'react-router-dom';

export default class RepositoryRow extends React.Component {
  render() {
    const { name: accountName } = this.props.account;
    const { name: repoName, manifest_count: manifestCount, tag_count: tagCount } = this.props.repo;

    return (
      <tr>
        <td className='col-md-4'>
          <Link to={`/repo/${accountName}/${repoName}`}>{repoName}</Link>
        </td>
        <td className='col-md-4'>{manifestCount}</td>
        <td className='col-md-4'>{tagCount}</td>
      </tr>
    );
  }
}
