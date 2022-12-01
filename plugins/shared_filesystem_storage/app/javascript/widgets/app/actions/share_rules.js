import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import React from "react"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

//################ SHARE RULES (ACCESS CONTROL) ################
const receiveShareRule = (shareId, rule) => ({
  type: constants.RECEIVE_SHARE_RULE,
  shareId,
  rule,
})
const requestDeleteShareRule = (shareId, ruleId) => ({
  type: constants.REQUEST_DELETE_SHARE_RULE,
  shareId,
  ruleId,
})
const deleteShareRuleFailure = (shareId, ruleId) => ({
  type: constants.DELETE_SHARE_RULE_FAILURE,
  shareId,
  ruleId,
})
const removeShareRule = (shareId, ruleId) => ({
  type: constants.DELETE_SHARE_RULE_SUCCESS,
  shareId,
  ruleId,
})
const removeShareRules = (shareId) => ({
  type: constants.DELETE_SHARE_RULES_SUCCESS,
  shareId,
})
const requestShareRules = (shareId) => ({
  type: constants.REQUEST_SHARE_RULES,
  requestedAt: Date.now(),
  shareId,
})
const receiveShareRules = (shareId, json) => ({
  type: constants.RECEIVE_SHARE_RULES,
  shareId,
  rules: json,
  receivedAt: Date.now(),
})
const fetchShareRules = (shareId) =>
  function (dispatch) {
    dispatch(requestShareRules(shareId))
    ajaxHelper
      .get(`/shares/${shareId}/rules`)
      .then((response) => dispatch(receiveShareRules(shareId, response.data)))
      .catch((error) => {
        // console.log(error)
        // return dispatch(app.showErrorDialog({title: 'Could not load share rules', message:jqXHR.responseText}));
      })
  }
const shouldFetchShareRules = function (state, shareId) {
  const shareRules = state.shareRules[shareId]
  if (!shareRules) return true
  if (!shareRules.isFetching && !shareRules.requestedAt) return true

  return false
}

const fetchShareRulesIfNeeded = (shareId) =>
  function (dispatch, getState) {
    if (shouldFetchShareRules(getState(), shareId)) {
      return dispatch(fetchShareRules(shareId))
    }
  }
const deleteShareRule = (shareId, ruleId) =>
  function (dispatch) {
    dispatch(requestDeleteShareRule(shareId, ruleId))
    ajaxHelper
      .delete(`/shares/${shareId}/rules/${ruleId}`)
      .then((response) => {
        if (response.data && response.data.errors) {
          dispatch(deleteShareRuleFailure(shareId, ruleId))
          addError(
            React.createElement(ErrorsList, { errors: response.data.errors })
          )
        } else {
          dispatch(removeShareRule(shareId, ruleId))
        }
      })
      .catch((error) =>
        addError(React.createElement(ErrorsList, { errors: error.message }))
      )
  }
//########################## SHARE RULE FORM #########################
const submitNewShareRule = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    let shareId = values.shareId
    delete values["shareId"]
    ajaxHelper
      .post(`/shares/${shareId}/rules`, { rule: values })
      .then((response) => {
        if (response.data.errors) handleErrors({ errors: response.data.errors })
        else {
          dispatch(receiveShareRule(shareId, response.data))
          handleSuccess()
        }
      })
      .catch((error) => handleErrors({ errors: error.message }))
  })
// export
export {
  submitNewShareRule,
  fetchShareRules,
  fetchShareRulesIfNeeded,
  deleteShareRule,
  removeShareRules,
}
