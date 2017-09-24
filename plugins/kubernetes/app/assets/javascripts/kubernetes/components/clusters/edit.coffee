#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, addNodePool, deleteNodePool, updateNodePoolForm, submitClusterForm } = kubernetes


EditCluster = ({
  close,
  clusterForm,
  handleSubmit,
  handleChange,
  handleNodePoolChange,
  handleNodePoolAdd,
  handleNodePoolRemove
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


      div className: 'toolbar toolbar-controlcenter',
        h4 null, "Nodepools"
        div className: 'main-control-buttons',
          button className: 'btn btn-primary', onClick: ((e) => e.preventDefault(); handleNodePoolAdd()),
            'Add Pool'

      for nodePool, i in cluster.spec.nodePools

        div className: 'nodepool-form', key: "nodepool-#{i}",
          form className: 'form form-inline form-inline-flex',
            h5 className: 'title', "Pool #{i+1}:"
            # Nodepool name
            div className: "form-group required string" ,
              label className: "string required control-label", htmlFor: "name",
                'Name '
                abbr title: "required", '*'


              input
                className: "string form-control",
                "data-index": i,
                disabled: 'disabled' if nodePool.name && !nodePool.new,
                type: "text",
                name: "name",
                value: nodePool.name || '',
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value))


            # Nodepool size
            div className: "form-group string" ,
              label className: "string control-label", htmlFor: "size",
                'Size '
                abbr title: "required", '*'

              input
                className: "string form-control",
                "data-index": i,
                type: "text",
                name: "size",
                placeholder: "Number of nodes"
                value: nodePool.size || '',
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, parseInt(e.target.value, 10)))

            # Nodepool flavor
            div className: "form-group string" ,
              label className: "string control-label", htmlFor: "flavor",
                'Flavor '
                abbr title: "required", '*'


              select
                name: "flavor",
                "data-index": i,
                className: "string form-control",
                disabled: 'disabled' if nodePool.flavor && !nodePool.new,
                value: (nodePool.flavor || ''),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                  option value: '', 'Choose flavor'
                  option value: 'm1.small', 'm1.small'
                  option value: 'm1.xsmall', 'm1.xsmall'
                  option value: 'm1.medium', 'm1.medium'
                  option value: 'm1.xmedium', 'm1.xmedium'
                  option value: 'm1.large', 'm1.large'
                  option value: 'm1.xlarge', 'm1.xlarge'


            button
              className: 'btn btn-default',
              "data-index": i,
              disabled: 'disabled' unless nodePool.new,
              onClick: ((e) -> e.preventDefault(); console.log("dataset: ", e.currentTarget.dataset.index); handleNodePoolRemove(e.target.dataset.index)),
                span className: "fa #{if nodePool.new then 'fa-trash' else 'fa-lock'}"





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
    handleNodePoolAdd:    ()                    -> dispatch(addNodePool())
    handleNodePoolRemove: (index)               -> dispatch(deleteNodePool(index))
    handleSubmit:         (callback)            -> dispatch(submitClusterForm(callback))

)(EditCluster)

kubernetes.EditClusterModal = ReactModal.Wrapper('Edit Cluster', EditCluster,
  large: true,
  closeButton: false,
  static: true
)
