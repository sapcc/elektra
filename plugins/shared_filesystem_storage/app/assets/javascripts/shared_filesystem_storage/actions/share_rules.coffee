((app) ->
  ################# SHARE RULES (ACCESS CONTROL) ################
  showAccessControlDialog=(shareId,networkId) ->
    type: ReactModal.SHOW_MODAL,
    modalType: 'SHARE_ACCESS_CONTROL',
    modalProps: {shareId, networkId}

  openShareAccessControlDialog=(shareId,networkId)->
    (dispatch) ->
      dispatch(app.shareRuleFormForCreate(shareId))
      dispatch(showAccessControlDialog(shareId,networkId))

  receiveShareRule=(shareId,rule)->
    type: app.RECEIVE_SHARE_RULE
    shareId: shareId
    rule: rule

  requestDeleteShareRule=(shareId,ruleId) ->
    type: app.REQUEST_DELETE_SHARE_RULE
    shareId: shareId
    ruleId: ruleId

  deleteShareRuleFailure=(shareId,ruleId) ->
    type: app.DELETE_SHARE_RULE_FAILURE
    shareId: shareId
    ruleId: ruleId

  removeShareRule=(shareId,ruleId) ->
    type: app.DELETE_SHARE_RULE_SUCCESS
    shareId: shareId
    ruleId: ruleId

  removeShareRules=(shareId) ->
    type: app.DELETE_SHARE_RULES_SUCCESS
    shareId: shareId

  requestShareRules= (shareId) ->
    type: app.REQUEST_SHARE_RULES
    shareId: shareId

  receiveShareRules= (shareId, json) ->
    type: app.RECEIVE_SHARE_RULES
    shareId: shareId
    rules: json
    receivedAt: Date.now()

  fetchShareRules= (shareId) ->
    (dispatch) ->
      dispatch(requestShareRules(shareId))
      app.ajaxHelper.get "/shares/#{shareId}/rules",
        success: (data, textStatus, jqXHR) ->
          dispatch(receiveShareRules(shareId,data))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(app.showErrorDialog(title: 'Could not load share rules', message:jqXHR.responseText))

  shouldFetchShareRules= (state, shareId) ->
    shareRules = state.shareRules[shareId]
    if !shareRules
      true
    else if shareRules.isFetching or shareRules.receivedAt
      false
    else
      false

  fetchShareRulesIfNeeded= (shareId) ->
    (dispatch, getState) ->
      dispatch(fetchShareRules(shareId)) if shouldFetchShareRules(getState(), shareId)

  deleteShareRule= (shareId,ruleId) ->
    (dispatch) ->
      dispatch(requestDeleteShareRule(shareId,ruleId))
      app.ajaxHelper.delete "/shares/#{shareId}/rules/#{ruleId}",
        success: (data, textStatus, jqXHR) ->
          if data and data.errors
            dispatch(deleteShareRuleFailure(shareId,ruleId))
            dispatch(app.showErrorDialog(title: 'Could not load share rules', message:jqXHR.responseText))
          else
            dispatch(removeShareRule(shareId,ruleId))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(deleteShareRuleFailure(shareId,ruleId))
          dispatch(app.showErrorDialog(title: 'Could not load share rules', message:jqXHR.responseText))

  ########################### SHARE RULE FORM #########################
  shareRuleFormForCreate=(shareId)->
    type: app.PREPARE_SHARE_RULE_FORM
    method: 'post'
    action: "/shares/#{shareId}/rules"

  updateShareRuleForm= (name,value) ->
    type: app.UPDATE_SHARE_RULE_FORM
    name: name
    value: value

  resetShareRuleForm= () ->
    type: app.RESET_SHARE_RULE_FORM

  shareRuleFormFailure=(errors) ->
    type: app.SHARE_RULE_FORM_FAILURE
    errors: errors

  showShareRuleForm=() ->
    type: app.SHOW_SHARE_RULE_FORM
  hideShareRuleForm=()->
    type: app.HIDE_SHARE_RULE_FORM

  submitShareRuleForm= (shareId, successCallback=null) ->
    (dispatch, getState) ->
      shareRuleForm = getState().shareRuleForm
      if shareRuleForm.isValid
        dispatch(type: app.SUBMIT_SHARE_RULE_FORM)
        app.ajaxHelper[shareRuleForm.method] shareRuleForm.action,
          data: { rule: shareRuleForm.data }
          success: (data, textStatus, jqXHR) ->
            if data.errors
              dispatch(shareRuleFormFailure(data.errors))
            else
              dispatch(receiveShareRule(shareId, data))
              dispatch(resetShareRuleForm())
              successCallback() if successCallback
          error: ( jqXHR, textStatus, errorThrown) ->
            dispatch(app.showErrorDialog(title: 'Could not save share rule', message:jqXHR.responseText))

  # export
  app.submitShareRuleForm         = submitShareRuleForm
  app.updateShareRuleForm         = updateShareRuleForm
  app.hideShareRuleForm           = hideShareRuleForm
  app.showShareRuleForm           = showShareRuleForm
  app.shareRuleFormForCreate      = shareRuleFormForCreate

  # export
  app.fetchShareRules              = fetchShareRules
  app.fetchShareRulesIfNeeded      = fetchShareRulesIfNeeded
  app.deleteShareRule              = deleteShareRule
  app.removeShareRules             = removeShareRules 
  app.openShareAccessControlDialog = openShareAccessControlDialog
)(shared_filesystem_storage)
