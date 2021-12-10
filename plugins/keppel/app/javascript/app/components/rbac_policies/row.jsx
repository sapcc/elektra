import { makeSelectBox } from '../utils';

const permsOptions = [
  { value: 'anonymous_pull', label: 'Pull anonymously' },
  { value: 'anonymous_first_pull', label: 'Pull anonymously (even new images)' },
  { value: 'pull', label: 'Pull' },
  { value: 'pull,push', label: 'Pull & Push' },
  { value: 'delete,pull,push', label: 'Pull & Push & Delete' },
  { value: 'delete,pull', label: 'Pull & Delete' },
  { value: 'delete', label: 'Delete' },
];

const RBACPoliciesEditRow = ({ index, policy, isEditable, isExternalReplica, setRepoRegex, setUserRegex, setSourceCIDR, setPermissions, removePolicy }) => {
  const { match_repository: repoRegex, match_username: userRegex, match_cidr: sourceCIDR } = policy;
  const currentPerms = policy.permissions.sort().join(',') || '';
  const currentPermsOptions = isExternalReplica ? permsOptions : permsOptions.filter(opt => opt.value != 'anonymous_first_pull');
  return (
    <tr>
      <td>
        {isEditable ? (
          <input type='text' value={repoRegex || ''}
            className='form-control'
            onChange={e => setRepoRegex(index, e.target.value)}
          />
        ) : repoRegex ? (
          <code>{repoRegex}</code>
        ) : (
          <em>Any</em>
        )}
      </td>
      <td>
        {isEditable ? (
          <input type='text' value={userRegex || ''}
            className='form-control'
            onChange={e => setUserRegex(index, e.target.value)}
            disabled={currentPerms == 'anonymous_pull' || currentPerms == 'anonymous_first_pull'}
          />
        ) : userRegex ? (
          <code>{userRegex}</code>
        ) : (
          <em>Any</em>
        )}
      </td>
      <td>
        {isEditable ? (
          <input type='text' value={sourceCIDR || ''}
            className='form-control'
            onChange={e => setSourceCIDR(index, e.target.value)}
          />
        ) : sourceCIDR ? (
          <code>{sourceCIDR}</code>
        ) : (
          <em>Any</em>
        )}
      </td>
      <td>
        {makeSelectBox({
          isEditable, options: currentPermsOptions, value: currentPerms,
          onChange: e => setPermissions(index, e.target.value),
        })}
      </td>
      <td>
        {isEditable && (
          <button className='btn btn-link' onClick={e => removePolicy(index)}>
            Remove
          </button>
        )}
      </td>
    </tr>
  );
};

export default RBACPoliciesEditRow;
