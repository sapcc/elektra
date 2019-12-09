export default class RepositoryRow extends React.Component {
  render() {
    const { name: repoName, manifest_count: manifestCount, tag_count: tagCount } = this.props.repo;

    return (
      <tr>
        {/* TODO link to tags/manifests list for repo */}
        <td className='col-md-4'>{repoName}</td>
        <td className='col-md-4'>{manifestCount}</td>
        <td className='col-md-4'>{tagCount}</td>
      </tr>
    );
  }
}
