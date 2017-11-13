#= require components/form_helpers

{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateShareNetworkForm, submitShareNetworkForm } = shared_filesystem_storage

EditShareNetwork = ({
  close,
  shareNetworkForm,
  handleSubmit,
  handleChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  shareNetwork = shareNetworkForm.data

  form className: 'form form-horizontal', onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
    div className: 'modal-body',
      if shareNetworkForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: shareNetworkForm.errors

      # Name
      div { className: "form-group string required shareNetwork_name" },
        label { className: "string required col-sm-4 control-label", htmlFor: "shareNetwork_name" },
          abbr { title: "required" }, "*"
          'Name'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input
              className: "string required form-control",
              type: "text",
              name: "name",
              value: (shareNetwork.name || ''),
              onChange: onChange

      # Description
      div { className: "form-group text optional shareNetwork_description" },
        label { className: "text optional col-sm-4 control-label", htmlFor: "shareNetwork_description" }, "Description"
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            textarea
              className: "text optional form-control",
              name: "description",
              value: (shareNetwork.description || ''),
              onChange: onChange


    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Update',
        loading: shareNetworkForm.isSubmitting,
        disabled: !shareNetworkForm.isValid
        onSubmit: (() -> handleSubmit(close))

EditShareNetwork = connect(
  (state) ->
    shareNetworkForm: state.shareNetworkForm
  (dispatch) ->
    handleChange: (name,value) -> dispatch(updateShareNetworkForm(name,value))
    handleSubmit: (callback) -> dispatch(submitShareNetworkForm(callback))
)(EditShareNetwork)

shared_filesystem_storage.EditShareNetworkModal = ReactModal.Wrapper('Edit Share Network', EditShareNetwork,
  large:true,
  closeButton: false,
  static: true
)
