//Returns null if the policy is valid, or an error message string otherwise.
export const validatePolicy = (policy) => {
  //NOTE: This function only checks for error states that can be reached via the policy edit UI.

  const rx = (attr) => policy[attr] || '';
  const tc = policy.time_constraint || {};
  if (rx('match_repository') === '.*' && rx('except_repository') === '' && rx('match_tag') === '' && rx('except_tag') === '' && !policy.only_untagged && !('on' in tc)) {
    return `need to configure at least one condition`;
  }

  if (rx('match_repository') == '') {
    return `repository name regex may not be empty`;
  }
  if (policy.ui_hints.tag_filter === 'on' && rx('match_tag') === '') {
    return `tag name regex may not be empty`;
  }

  if (('oldest' in tc) && policy.action == 'delete') {
    return `match for 'oldest X' is only allowed for 'protect' policies`;
  }
  if (('newest' in tc) && policy.action == 'delete') {
    return `match for 'newest X' is only allowed for 'protect' policies`;
  }
  if (('on' in tc) && (['oldest', 'newest', 'older_than', 'newer_than'].every(attr => !(attr in tc)))) {
    return `need to select a time constraint`;
  }

  return null;
};
