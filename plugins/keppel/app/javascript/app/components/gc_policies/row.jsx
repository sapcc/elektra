import { makeSelectBox } from '../utils';

const actionOptions = [
  { value: 'protect', label: 'Protect image' },
  { value: 'delete', label: 'Delete image' },
];
const repoFilterOptions = [
  { value: 'off', label: 'regardless of repository' },
  { value: 'on', label: 'if repository name matches' },
];
const tagFilterOptions = [
  { value: 'off', label: 'regardless of tags' },
  { value: 'on', label: 'if tag name matches' },
  { value: 'untagged', label: 'if image does not have tags' },
];

const GCPoliciesEditRow = ({ index, policy, policyCount, isEditable, movePolicy, setPolicyAttribute, removePolicy }) => {
  const makeTextInput = (attr, value) => {
    value = value || '';
    if (!isEditable) {
      if (value === '') {
        return <em>Any</em>;
      }
      return <code>{value || ''}</code>;
    }
    return (
      <input type='text' value={value} className='form-control'
        onChange={e => setPolicyAttribute(index, attr, e.target.value)}
      />
    );
  };

  return (
    <tr>
      {isEditable ? (
        <td key='order' className='policy-order-buttons'>
          {(index > 0) ? (
            <button className='btn btn-xs btn-default' onClick={e => movePolicy(index, -1)}>Move up</button>
          ) : (
            <button className='btn btn-xs btn-default' disabled={true}>Move up</button>
          )}
          {(index < policyCount - 1) ? (
            <button className='btn btn-xs btn-default' onClick={e => movePolicy(index, +1)}>Move down</button>
          ) : (
            <button className='btn btn-xs btn-default' disabled={true}>Move down</button>
          )}
        </td>
      ) : (
        <td key='order' className='policy-order-buttons'></td>
      )}
      <td>
        {makeSelectBox({
          isEditable, options: actionOptions, value: policy.action,
          onChange: e => setPolicyAttribute(index, "action", e.target.value),
        })}
      </td>
      <td className="form-inline">
        <div className='policy-matching-rule-line'>
          {makeSelectBox({
            isEditable, options: repoFilterOptions, value: policy.ui_hints.repo_filter,
            onChange: e => setPolicyAttribute(index, "repo_filter", e.target.value),
          })}
          {policy.ui_hints.repo_filter == 'on' && (
            <React.Fragment>
              {" "}
              {makeTextInput('match_repository', policy.match_repository)}
              {(isEditable || policy.except_repository) && (
                <React.Fragment>
                  {" but not "}
                  {makeTextInput('except_repository', policy.except_repository)}
                </React.Fragment>
              )}
            </React.Fragment>
          )}
        </div>
        <div className='policy-matching-rule-line'>
          {makeSelectBox({
            isEditable, options: tagFilterOptions, value: policy.ui_hints.tag_filter,
            onChange: e => setPolicyAttribute(index, "tag_filter", e.target.value),
          })}
          {policy.ui_hints.tag_filter == 'on' && (
            <React.Fragment>
              {" "}
              {makeTextInput('match_tag', policy.match_tag)}
              {(isEditable || policy.except_tag) && (
                <React.Fragment>
                  {" but not "}
                  {makeTextInput('except_tag', policy.except_tag)}
                </React.Fragment>
              )}
            </React.Fragment>
          )}
        </div>
        <div className='policy-matching-rule-line'>
          TODO: show/edit time constraint
        </div>
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

export default GCPoliciesEditRow;
