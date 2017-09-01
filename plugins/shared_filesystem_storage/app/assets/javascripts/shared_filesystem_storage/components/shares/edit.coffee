#= require components/form_helpers

{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateShareForm, submitShareForm } = shared_filesystem_storage
protocols= ['NFS']

EditShare = ({
  close,
  shareForm,
  shareNetworks,
  handleSubmit,
  handleChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  share = shareForm.data

  div null,
    div className: 'modal-body',
      form className: 'form form-horizontal', onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
        div className: 'modal-body',
          if shareForm.errors
            div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: shareForm.errors

          # Name
          div className: "form-group string  share_name" ,
            label className: "string  col-sm-4 control-label", htmlFor: "share_name", 'Name'
            div className: "col-sm-8",
              div className: "input-wrapper",
                input
                  className: "string required form-control",
                  type: "text",
                  name: "name",
                  value: share.name || '',
                  onChange: onChange

          # Description
          div className: "form-group text optional share_description",
            label className: "text optional col-sm-4 control-label", htmlFor: "share_description", "Description"
            div className: "col-sm-8",
              div className: "input-wrapper",
                textarea
                  className: "text optional form-control",
                  name: "description",
                  value: (share.description || ''),
                  onChange: onChange

    div className: 'modal-footer',
      button role: 'cancel', type: 'button', className: 'btn btn-default', onClick: close, 'Cancel'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Save',
        loading: shareForm.isSubmitting,
        disabled: !shareForm.isValid
        onSubmit: (() -> handleSubmit(close))

EditShare = connect(
  (state) ->
    shareForm: state.shareForm
  (dispatch) ->
    handleChange: (name,value) -> dispatch(updateShareForm(name,value))
    handleSubmit: (callback) -> dispatch(submitShareForm(callback))
)(EditShare)

shared_filesystem_storage.EditShareModal = ReactModal.Wrapper('Edit Share', EditShare,
  large:true,
  closeButton: false,
  static: true
)
