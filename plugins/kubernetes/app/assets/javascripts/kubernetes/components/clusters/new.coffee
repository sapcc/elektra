#= require components/form_helpers


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, updateNodePoolForm, submitClusterForm } = kubernetes


NewCluster = ({
  close,
  clusterForm,
  handleSubmit,
  handleChange,
  handleNodePoolChange
}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)


  cluster = clusterForm.data
  div null,
    div className: 'modal-body',
      if clusterForm.errors
        div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: clusterForm.errors

      form className: 'form form-horizontal',
        # Name
        div className: "form-group required string  cluster_name" ,
          label className: "string required col-sm-4 control-label", htmlFor: "name",
            abbr title: "required", '*'
            ' Cluster Name'
          div className: "col-sm-8",
            div className: "input-wrapper",
              input
                className: "string required form-control",
                type: "text",
                name: "name",
                value: cluster.name || '',
                onChange: onChange


      div className: 'toolbar',
        h4 null, "Nodepools"

      div className: 'nodepool-form',
        form className: 'form form-inline form-inline-flex',
          h5 className: 'title', 'Pool 1:'
          # Nodepool name
          div className: "form-group required string" ,
            label className: "string required control-label", htmlFor: "name",
              'Name '
              abbr title: "required", '*'

            input
              className: "string form-control",
              type: "text",
              name: "name",
              value: cluster.spec.nodepools[0].name || '',
              onChange: ((e) -> e.preventDefault; handleNodePoolChange(0, e.target.name, e.target.value))

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
              value: cluster.spec.nodepools[0].size || '',
              onChange: ((e) -> e.preventDefault; handleNodePoolChange(0, e.target.name, e.target.value))

          # Nodepool flavor
          div className: "form-group string" ,
            label className: "string control-label", htmlFor: "flavor",
              'Flavor '
              abbr title: "required", '*'

            select
              name: "flavor",
              className: "select required form-control",
              value: (cluster.spec.nodepools[0].flavor || ''),
              onChange: ((e) -> e.preventDefault; handleNodePoolChange(0, e.target.name, e.target.value)),

                option value: 'm1.small', 'm1.small'
                option value: 'm1.xsmall', 'm1.xsmall'
                option value: 'm1.medium', 'm1.medium'
                option value: 'm1.xmedium', 'm1.xmedium'
                option value: 'm1.large', 'm1.large'
                option value: 'm1.xlarge', 'm1.xlarge'



            # input
            #   className: "string form-control",
            #   type: "text",
            #   name: "flavor",
            #   value: cluster.spec.nodepools[0].flavor || '',
            #   onChange: ((e) -> e.preventDefault; handleNodePoolChange(0, e.target.name, e.target.value))

#       <option value="88813ab0-8f42-4d36-add1-9322187f2f56">baremetal  (RAM: 16 MiB, VCPUs: 1, Disk: 100 GiB )</option>
# <option value="10">m1.tiny  (RAM: 512 MiB, VCPUs: 1, Disk: 1 GiB )</option>
# <option value="20">m1.small  (RAM: 2 GiB, VCPUs: 2, Disk: 16 GiB )</option>
# <option value="22">m1.xsmall  (RAM: 4 GiB, VCPUs: 2, Disk: 64 GiB )</option>
# <option value="30">m1.medium  (RAM: 4 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="32">m1.xmedium  (RAM: 8 GiB, VCPUs: 2, Disk: 64 GiB )</option>
# <option value="40">m1.large  (RAM: 8 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="50">m1.xlarge  (RAM: 16 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="110">m2.xlarge  (RAM: 16 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="120">m2.2xlarge  (RAM: 24 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="60">m1.2xlarge  (RAM: 32 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="130">m2.3xlarge  (RAM: 48 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="100">m2.large  (RAM: 64 GiB, VCPUs: 4, Disk: 64 GiB )</option>
# <option value="140">m2.4xlarge  (RAM: 64 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="70">m1.4xlarge  (RAM: 64 GiB, VCPUs: 16, Disk: 64 GiB )</option>
# <option value="90">x1.memory  (RAM: 128 GiB, VCPUs: 8, Disk: 64 GiB )</option>
# <option value="80">m1.10xlarge  (RAM: 160 GiB, VCPUs: 40, Disk: 64 GiB )</option>
# <option value="99">x1.2xmemory  (RAM: 256 GiB, VCPUs: 16, Disk: 64 GiB )</option>
# <option value="150">x1.4xmemory  (RAM: 512 GiB, VCPUs: 32, Disk: 64 GiB )</option>



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
    handleChange:         (name, value)         -> dispatch(updateClusterForm(name, value))
    handleNodePoolChange: (index, name, value)  -> dispatch(updateNodePoolForm(index, name, value))
    handleSubmit:         (callback)            -> dispatch(submitClusterForm(callback))

)(NewCluster)

kubernetes.NewClusterModal = ReactModal.Wrapper('Create Cluster', NewCluster,
  large: true,
  closeButton: false,
  static: true
)
