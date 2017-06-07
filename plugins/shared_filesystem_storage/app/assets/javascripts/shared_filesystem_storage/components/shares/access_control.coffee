#= require shared_filesystem_storage/components/shares/access_control_form
#= require shared_filesystem_storage/components/shares/access_control_item
#= require react/transition_groups

{ div,table,thead,tbody,tr,th,td,form,select,h4,label,span,input,button,abbr,select,option,a,i,small } = React.DOM
{ connect } = ReactRedux
{
  updateShareRuleForm,
  submitShareRuleForm,
  hideShareRuleForm,
  showShareRuleForm,
  deleteShareRule,
  AccessControlForm,
  AccessControlItem
} = shared_filesystem_storage

AccessControl = ({
  shareId,
  shareNetwork,
  isFetching,
  shareRules,
  close,
  handleChange,
  handleSubmit,
  handleDelete,
  hideForm,
  showForm,
  ruleForm
}) ->

  div null,
    div className: 'modal-body',
      if shareRules.isFetching
        div null,
          span className: 'spinner', null
          'Loading...'
      else
        table { className: 'table share-rules' },
          thead null,
            tr null,
              th null, 'Access Type'
              th null, 'Access to'
              th null, 'Access Level'
              th null, 'Status'
              th className: 'snug'
          tbody null,
            if shareRules.items.length==0
              tr null,
                td colSpan: 5, 'No Rules found.'
            else
              for rule in shareRules.items
                React.createElement AccessControlItem, key: rule.id, rule: rule, shareNetwork: shareNetwork, handleDelete: handleDelete

            tr null,
              td colSpan: 4,
                ReactTransitionGroups.Fade null,
                  unless ruleForm.isHidden
                    React.createElement AccessControlForm, { handleChange, handleSubmit, ruleForm }
              td null,
                unless ruleForm.isHidden
                  a
                    className: 'btn btn-default btn-sm',
                    href: '#',
                    onClick: ((e) -> e.preventDefault(); hideForm()),
                    i className: 'fa fa-close'
                else
                  a
                    className: 'btn btn-primary btn-sm',
                    href: '#',
                    onClick: ((e) -> e.preventDefault(); showForm()),
                    i className: 'fa fa-plus'

    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'

AccessControl = connect(
  (state,ownProps) ->
    shareRules: (state.shareRules[ownProps.shareId] || {items: [], isFetching: false})
    shareNetwork: state.shareNetworks.items.find((n) -> n.id==ownProps.networkId)
    ruleForm: state.shareRuleForm
  (dispatch,ownProps) ->
    handleChange: (name,value) -> dispatch(updateShareRuleForm(name,value))
    handleSubmit: -> dispatch(submitShareRuleForm(ownProps.shareId))
    handleDelete: (ruleId) -> dispatch(deleteShareRule(ownProps.shareId,ruleId))
    hideForm: -> dispatch(hideShareRuleForm())
    showForm: -> dispatch(showShareRuleForm())
)(AccessControl)
shared_filesystem_storage.ShareAccessControl = ReactModal.Wrapper('Share Access Control', AccessControl,
  large:true
)
