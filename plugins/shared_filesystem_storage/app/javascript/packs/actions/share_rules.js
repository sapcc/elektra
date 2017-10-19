import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

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
    return ajaxHelper.delete(`/shares/${shareId}/rules/${ruleId}`, {
      success(data, textStatus, jqXHR) {
        if (data && data.errors) {
          dispatch(deleteShareRuleFailure(shareId,ruleId));
          return dispatch(app.showErrorDialog({title: 'Could not load share rules', message:jqXHR.responseText}));
        } else {
          return dispatch(removeShareRule(shareId,ruleId));
        }
      },
      error( jqXHR, textStatus, errorThrown) {
        dispatch(deleteShareRuleFailure(shareId,ruleId));
        return dispatch(app.showErrorDialog({title: 'Could not load share rules', message:jqXHR.responseText}));
      }
    }
    );
  }
;

//########################## SHARE RULE FORM #########################
const shareRuleFormForCreate=shareId=>
  ({
    type: constants.PREPARE_SHARE_RULE_FORM,
    method: 'post',
    action: `/shares/${shareId}/rules`
  })
;

const updateShareRuleForm= (name,value) =>
  ({
    type: constants.UPDATE_SHARE_RULE_FORM,
    name,
    value
  })
;

const resetShareRuleForm= () => ({type: constants.RESET_SHARE_RULE_FORM});

const shareRuleFormFailure=errors =>
  ({
    type: constants.SHARE_RULE_FORM_FAILURE,
    errors
  })
;

const showShareRuleForm=shareId => ({type: constants.SHOW_SHARE_RULE_FORM});

const hideShareRuleForm=()=> ({type: constants.HIDE_SHARE_RULE_FORM});

const submitShareRuleForm= (shareId, successCallback=null) =>
  function(dispatch, getState) {
    const { shareRuleForm } = getState();
    if (shareRuleForm.isValid) {
      dispatch({type: app.SUBMIT_SHARE_RULE_FORM});
      return app.ajaxHelper[shareRuleForm.method](shareRuleForm.action, {
        data: { rule: shareRuleForm.data },
        success(data, textStatus, jqXHR) {
          if (data.errors) {
            return dispatch(shareRuleFormFailure(data.errors));
          } else {
            dispatch(receiveShareRule(shareId, data));
            dispatch(resetShareRuleForm());
            if (successCallback) { return successCallback(); }
          }
        },
        error( jqXHR, textStatus, errorThrown) {
          return dispatch(app.showErrorDialog({title: 'Could not save share rule', message:jqXHR.responseText}));
        }
      }
      );
    }
  }
;

// export
export {
  submitShareRuleForm,
  updateShareRuleForm,
  hideShareRuleForm,
  showShareRuleForm,
  shareRuleFormForCreate,
  fetchShareRules,
  fetchShareRulesIfNeeded,
  deleteShareRule,
  removeShareRules,
  openShareAccessControlDialog
}
