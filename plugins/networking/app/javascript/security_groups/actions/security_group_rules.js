import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const ajaxHelper = pluginAjaxHelper('networking')

const errorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message


//################### SECURITY GROUP RULE #########################
const receiveSecurityGroupRule= (securityGroupId, securityGroupRule) =>
  ({
    type: constants.RECEIVE_SECURITY_GROUP_RULE,
    securityGroupId,
    securityGroupRule
  })
;

const requestSecurityGroupRuleDelete= (securityGroupId, id) => (
  {
    type: constants.REQUEST_SECURITY_GROUP_RULE_DELETE,
    securityGroupId,
    id
  }
)

const removeSecurityGroupRule= (securityGroupId, id) => (
  {
    type: constants.REMOVE_SECURITY_GROUP_RULE,
    securityGroupId,
    id
  }
)

const deleteSecurityGroupRule=(securityGroupId, id) =>
  (dispatch) =>
    confirm(`Do you really want to delete the rule ${id}?`).then(() => {
      dispatch(requestSecurityGroupRuleDelete(securityGroupId, id))
      return ajaxHelper.delete(`/security-groups/${securityGroupId}/rules/${id}`)
      .then(response => dispatch(removeSecurityGroupRule(securityGroupId, id)))
      .catch( (error) => {
        addError(React.createElement(ErrorsList, {
          errors: errorMessage(error)
        }))
      });
    }).catch(cancel => true)

const submitNewSecurityGroupRuleForm= (securityGroupId, values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.post(`/security-groups/${securityGroupId}/rules`, { security_group_rule: values }
      ).then((response) => {
        dispatch(receiveSecurityGroupRule(securityGroupId, response.data))
        handleSuccess()
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

export {
  deleteSecurityGroupRule,
  submitNewSecurityGroupRuleForm
}
