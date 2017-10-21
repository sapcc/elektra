import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm, showInfoModal, showErrorModal } from 'dialogs';

//################ SHARE RULES (ACCESS CONTROL) ################
const receiveShareRule=(shareId,rule)=>
  ({
    type: constants.RECEIVE_SHARE_RULE,
    shareId,
    rule
  })
;

const requestDeleteShareRule=(shareId,ruleId) =>
  ({
    type: constants.REQUEST_DELETE_SHARE_RULE,
    shareId,
    ruleId
  })
;

const deleteShareRuleFailure=(shareId,ruleId) =>
  ({
    type: constants.DELETE_SHARE_RULE_FAILURE,
    shareId,
    ruleId
  })
;

const removeShareRule=(shareId,ruleId) =>
  ({
    type: constants.DELETE_SHARE_RULE_SUCCESS,
    shareId,
    ruleId
  })
;

const removeShareRules=shareId =>
  ({
    type: constants.DELETE_SHARE_RULES_SUCCESS,
    shareId
  })
;

const requestShareRules= shareId =>
  ({
    type: constants.REQUEST_SHARE_RULES,
    shareId
  })
;

const receiveShareRules= (shareId, json) =>
  ({
    type: constants.RECEIVE_SHARE_RULES,
    shareId,
    rules: json,
    receivedAt: Date.now()
  })
;

const fetchShareRules= shareId =>
  function(dispatch) {
    dispatch(requestShareRules(shareId));
    ajaxHelper.get(`/shares/${shareId}/rules`)
      .then( (response) => dispatch(receiveShareRules(shareId,response.data)))
      .catch((error) => {
        console.log(error)
        // return dispatch(app.showErrorDialog({title: 'Could not load share rules', message:jqXHR.responseText}));
      })
  }
;

const shouldFetchShareRules= function(state, shareId) {
  const shareRules = state.shared_filesystem_storage.shareRules[shareId];
  if (!shareRules) {
    return true;
  } else if (shareRules.isFetching || shareRules.receivedAt) {
    return false;
  } else {
    return false;
  }
};

const fetchShareRulesIfNeeded= shareId =>
  function(dispatch, getState) {
    if (shouldFetchShareRules(getState(), shareId)) { return dispatch(fetchShareRules(shareId)); }
  }
;

const deleteShareRule= (shareId,ruleId) =>
  function(dispatch) {
    dispatch(requestDeleteShareRule(shareId,ruleId));
    ajaxHelper.delete(`/shares/${shareId}/rules/${ruleId}`).then(response => {
      if (response.data && response.data.errors) {
        dispatch(deleteShareRuleFailure(shareId,ruleId));
        showErrorModal(React.createElement(ErrorsList, {errors}));
      } else {
        dispatch(removeShareRule(shareId,ruleId));
      }
    }).catch(error => showErrorModal(
      React.createElement(ErrorsList, {errors: error.message})
    ))
  }
;

//########################## SHARE RULE FORM #########################
const submitNewShareRule= (values, {handleSuccess,handleErrors}) =>
  function(dispatch) {
    let shareId = values.shareId
    delete values['shareId']
    ajaxHelper.post(`/shares/${shareId}/rules`, { rule: values }).then(response => {
      if (response.data.errors) {
        handleErrors(response.data.errors)
      } else {
        dispatch(receiveShareRule(shareId, response.data));
        if(handleSuccess) handleSuccess()
      }
    }).catch(error => showErrorModal(
      React.createElement(ErrorsList, {errors: error.message})
    ))
  }
;

// export
export {
  submitNewShareRule,
  fetchShareRules,
  fetchShareRulesIfNeeded,
  deleteShareRule,
  removeShareRules
}
