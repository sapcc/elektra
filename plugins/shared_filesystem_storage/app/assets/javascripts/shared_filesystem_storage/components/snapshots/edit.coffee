#= require components/form_helpers

{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateSnapshotForm, submitSnapshotForm } = shared_filesystem_storage
protocols= ['NFS']

EditSnapshot = ({
  close,
  snapshotForm,
  handleSubmit,
  handleChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  snapshot = snapshotForm.data

  form className: 'form form-horizontal', onSubmit: handleSubmit,
    div className: 'modal-body',
      if snapshotForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: snapshotForm.errors

      # Name
      div { className: "form-group string  snapshot_name" },
        label { className: "string  col-sm-4 control-label", htmlFor: "snapshot_name" }, 'Name'
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            input { className: "string required form-control", type: "text", name: "name", value: (snapshot.name || ''), onChange: onChange }

      # Description
      div { className: "form-group text optional snapshot_description" },
        label { className: "text optional col-sm-4 control-label", htmlFor: "snapshot_description" }, "Description"
        div { className: "col-sm-8" },
          div { className: "input-wrapper" },
            textarea { className: "text optional form-control", name: "description", value: (snapshot.description || ''), onChange: onChange }

    div className: 'modal-footer',
      button role: 'cancel', type: 'button', className: 'btn btn-default', onClick: close, 'Cancel'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Save',
        loading: snapshotForm.isSubmitting,
        disabled: !snapshotForm.isValid
        onSubmit: (() -> handleSubmit(close))

EditSnapshot = connect(
  (state) ->
    snapshotForm: state.snapshotForm
  (dispatch) ->
    handleChange: (name,value) -> dispatch(updateSnapshotForm(name,value))
    handleSubmit: (callback) -> dispatch(submitSnapshotForm(callback))
)(EditSnapshot)

shared_filesystem_storage.EditSnapshotModal = ReactModal.Wrapper('Edit Snapshot', EditSnapshot,
  large:true,
  closeButton: false,
  static: true
)
