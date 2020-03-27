const permsOptions = [
  { value: 'anonymous_pull', label: 'Pull anonymously' },
  { value: 'pull', label: 'Pull' },
  { value: 'pull,push', label: 'Pull & Push' },
  { value: 'delete,pull,push', label: 'Pull & Push & Delete' },
  { value: 'delete,pull', label: 'Pull & Delete' },
  { value: 'delete', label: 'Delete' },
];

const RBACPoliciesEditRow = ({ index, policy, isEditable, setRepoRegex, setUserRegex, setPermissions, removePolicy }) => {
  const { match_repository: repoRegex, match_username: userRegex } = policy;
  const currentPerms = policy.permissions.sort().join(',') || '';
  const currentPermsOption = permsOptions.find(o => o.value == currentPerms);
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
            disabled={currentPerms == 'anonymous_pull'}
          />
        ) : userRegex ? (
          <code>{userRegex}</code>
        ) : (
          <em>Any</em>
        )}
      </td>
      <td>
        {isEditable ? (
          <select value={currentPerms} className='form-control select'
              onChange={e => setPermissions(index, e.target.value)}>
            {!currentPermsOption && (
              <option key='unknown' value={currentPerms}>-- Please select --</option>
            )}
            {permsOptions.map(o => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))}
          </select>
        ) : (
          currentPermsOption ? currentPermsOption.label : ''
        )}
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
