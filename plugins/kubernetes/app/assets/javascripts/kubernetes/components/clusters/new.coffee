#= require react/form_helpers


{ div,form,input,textarea,h4,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, submitClusterForm } = kubernetes


NewCluster = ({
  close,
  clusterForm,
  handleSubmit,
  handleChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)

  cluster = clusterForm.data
  form className: 'form form-horizontal', onSubmit: ((e) -> e.preventDefault(); handleSubmit()),
    div className: 'modal-body',
      if clusterForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: clusterForm.errors

      # Name
      div className: "form-group required string  cluster_name" ,
        label className: "string required col-sm-4 control-label", htmlFor: "cluster_name",
          abbr title: "required", '*'
          ' Name'
        div className: "col-sm-8",
          div className: "input-wrapper",
            input
              className: "string required form-control",
              type: "text",
              name: "name",
              value: cluster.name || '',
              onChange: onChange


    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Create',
        loading: clusterForm.isSubmitting,
        disabled: !clusterForm.isValid
        onSubmit: (() -> handleSubmit(close))

NewCluster = connect(
  (state) ->
    clusterForm: state.clusterForm

  (dispatch) ->
    handleChange: (name, value) -> dispatch(updateClusterForm(name, value))
    handleSubmit: (callback)    -> dispatch(submitClusterForm(callback))

)(NewCluster)

kubernetes.NewClusterModal = ReactModal.Wrapper('Create Cluster', NewCluster,
  large: true,
  closeButton: false,
  static: true
)
