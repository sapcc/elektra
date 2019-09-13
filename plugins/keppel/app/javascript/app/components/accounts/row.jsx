export default class AccountRow extends React.Component {
  render() {
    const {
      name:           accountName,
      auth_tenant_id: projectID,
      rbac_policies:  policies,
    } = this.props.account;

    const swiftContainerURL = `/_/${projectID}/object-storage/containers/${accountName}/list`;

    return (
      <tr>
        <td className='col-md-3'>{accountName}</td>
        <td className='col-md-3'>
          Swift container
          {' '}
          <a href={swiftContainerURL}>keppel-{accountName}</a>
        </td>
        <td className='col-md-5'><pre>{JSON.stringify(policies, null, 2)}</pre></td>
        <td className='col-md-1'>TODO</td>
      </tr>
    );
  }
}
