#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, updateNodePoolForm, submitClusterForm } = kubernetes


EditCluster = ({
  close,
  clusterForm,
  handleSubmit,
  handleChange,
  handleNodePoolChange
}) ->

  cluster = clusterForm.data
  div null,
    div className: 'modal-body',
      if clusterForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: clusterForm.errors

      form className: 'form form-horizontal',
        # Name
        div className: "form-group string  cluster_name" ,
          label className: "string col-sm-4 control-label", htmlFor: "name",
            'Cluster Name'
          div className: "col-sm-8",
            div className: "input-wrapper",
              input
                className: "string form-control disabled",
                disabled: 'disabled',
                type: "text",
                name: "name",
                value: cluster.name || ''


      div className: 'toolbar',
        h4 null, "Nodepools"

      div className: 'nodepool-form',
        form className: 'form form-inline form-inline-flex',
          h5 className: 'title', 'Pool 1:'
          # Nodepool name
          div className: "form-group required string" ,
            label className: "string required control-label", htmlFor: "name",
              'Name '

            input
              className: "string form-control disabled",
              disabled: 'disabled',
              type: "text",
              name: "name",
              value: cluster.spec.nodePools[0].name || ''

          # Nodepool size
          div className: "form-group string" ,
            label className: "string control-label", htmlFor: "size",
              'Size '
              abbr title: "required", '*'

            input
              className: "string form-control",
              type: "text",
              name: "size",
              placeholder: "Number of nodes"
              value: cluster.spec.nodePools[0].size || '',
              onChange: ((e) -> e.preventDefault; handleNodePoolChange(0, e.target.name, parseInt(e.target.value, 10)))

          # Nodepool flavor
          div className: "form-group string" ,
            label className: "string control-label", htmlFor: "flavor",
              'Flavor '

            input
              name: "flavor",
              className: "string form-control disabled",
              disabled: 'disabled',
              value: (cluster.spec.nodePools[0].flavor || '')





    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Update',
        loading: clusterForm.isSubmitting,
        disabled: !clusterForm.isValid
        onSubmit: (() -> handleSubmit(close))

EditCluster = connect(
  (state) ->
    clusterForm: state.clusterForm

  (dispatch) ->
    handleChange:         (name, value)         -> dispatch(updateClusterForm(name, value))
    handleNodePoolChange: (index, name, value)  -> dispatch(updateNodePoolForm(index, name, value))
    handleSubmit:         (callback)            -> dispatch(submitClusterForm(callback))

)(EditCluster)

kubernetes.EditClusterModal = ReactModal.Wrapper('Edit Cluster', EditCluster,
  large: true,
  closeButton: false,
  static: true
)
