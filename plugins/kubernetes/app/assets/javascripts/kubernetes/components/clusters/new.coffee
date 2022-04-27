#= require components/form_helpers
#= require kubernetes/components/clusters/advancedoptions


{ div,form,input,textarea,h4, h5,label,span,button,abbr,select,option,optgroup,p,i,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, addNodePool, deleteNodePool, updateNodePoolForm, submitClusterForm, AdvancedOptions, toggleAdvancedOptions, updateSSHKey, updateKeyPair  } = kubernetes


NewCluster = ({
  close,
  clusterForm,
  metaData,
  info,
  handleSubmit,
  handleChange,
  handleNodePoolChange,
  handleNodePoolAdd,
  handleNodePoolRemove,
  handleAdvancedOptionsToggle,
  handleSSHKeyChange,
  handleKeyPairChange


}) ->
  onChange=(e) ->
    e.preventDefault()
    handleChange(e.target.name,e.target.value)


  cluster = clusterForm.data
  spec    = cluster.spec
  defaultAZName = metaData.availabilityZones[0].name if metaData.loaded

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
                placeholder: "lower case letters and numbers",
                value: cluster.name || '',
                onChange: onChange


        # Keypair
        div null,
          div className: "form-group string" ,
            label className: "string col-sm-4 control-label", htmlFor: "keypair",
              ' Key Pair'
            div className: "col-sm-8",
              div className: "input-wrapper",
                select
                  name: "keypair",
                  className: "select form-control",
                  value: (spec.keyPair || ''),
                  onChange: ((e) -> handleKeyPairChange(e.target.value)),

                    if metaData.keyPairs?
                      optgroup label: "Choose from personal keys or provide other",
                        option value: '', "None"

                        for keyPair in metaData.keyPairs
                          option value: keyPair.publicKey, key: keyPair.name, keyPair.name

                        option value: 'other', "Other"
                    else
                      option value: '', "Loading..."

        # SSH Public Key
        if metaData.keyPairs? && spec.keyPair == 'other'
          div null,
            div className: "form-group required string" ,
              label className: "string required col-sm-4 control-label", htmlFor: "sshkey",
                ' SSH Public Key'
              div className: "col-sm-8",
                div className: "input-wrapper",
                  textarea
                    name: "sshkey",
                    className: "form-control",
                    value: (spec.sshPublicKey || ''),
                    onChange: ((e) -> handleSSHKeyChange(e.target.value)),
                    rows: 6,
                    placeholder: 'Please paste any valid SSH public key'


        p className: 'u-clearfix',
          a className: 'pull-right', onClick: ((e) => e.preventDefault(); handleAdvancedOptionsToggle()), href: '#',
            "#{if clusterForm.advancedOptionsVisible then 'Hide ' else ''}Advanced Options"

        if clusterForm.advancedOptionsVisible
            React.createElement AdvancedOptions, clusterForm: clusterForm, metaData: metaData, info: info,



      # ------- NODEPOOLS --------


      div className: 'toolbar',
        h4 null, "Nodepools"
        div className: 'main-buttons',
          if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
            button className: 'btn btn-default', disabled: 'disabled',
              span className: 'spinner'
          else
            button className: 'btn btn-primary', onClick: ((e) => e.preventDefault(); handleNodePoolAdd(defaultAZName)),
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
                type: "text",
                name: "name",
                placeholder: "a-z + 0-9",
                value: nodePool.name || '',
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value))


            # Nodepool flavor
            div className: "form-group string" ,
              label className: "string control-label", htmlFor: "flavor",
                'Flavor '
                abbr title: "required", '*'

              select
                name: "flavor",
                "data-index": i,
                className: "select required form-control",
                value: (nodePool.flavor || ''),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                  if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
                    option value: '', 'Loading...'
                  else
                    if metaData.flavors?
                      for flavor, f_index in metaData.flavors
                        flavorMetaData = if flavor.ram? && flavor.vcpus? then "(ram: #{flavor.ram}, vcpus: #{flavor.vcpus})" else ""
                        option value: flavor.name, key: f_index, "#{flavor.name} #{flavorMetaData}"


            # Nodepool Availability Zone
            div className: "form-group string" ,
              label className: "string control-label", htmlFor: "az",
                'Availability Zone '
                abbr title: "required", '*'


              select
                name: "availabilityZone",
                "data-index": i,
                className: "string form-control",
                disabled: 'disabled' if nodePool.availabilityZone && !nodePool.new,
                value: (nodePool.availabilityZone || defaultAZName),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                  if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
                    option value: '', 'Loading...'
                  else
                    if metaData.availabilityZones?
                      for az in metaData.availabilityZones
                        option value: az.name, key: az.name, "#{az.name}"


            # Nodepool size
            div className: "form-group form-group-size" ,
              label className: "string control-label", htmlFor: "size",
                'Size '
                abbr title: "required", '*'

              input
                className: "form-control",
                "data-index": i,
                type: "number",
                name: "size",
                min: "0",
                placeholder: "0",
                value: (if isNaN(nodePool.size) then '' else nodePool.size),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, parseInt(e.target.value, 10)))


            # Nodepool Allow Reboot
            div className: "checkbox inline-checkbox form-group" ,
              label className: "string control-label",
                input 
                  type: "checkbox", 
                  "data-index": i, 
                  checked: (nodePool.config.allowReboot), 
                  onChange: ((e) -> handleNodePoolChange(e.target.dataset.index, "allowReboot", !nodePool.config.allowReboot))
                "Allow Reboot"

            # Nodepool Allow Replace
            div className: "checkbox inline-checkbox form-group" ,
              label className: "string control-label",
                input 
                  type: "checkbox", 
                  "data-index": i, 
                  checked: (nodePool.config.allowReplace),
                  onChange: ((e) -> handleNodePoolChange(e.target.dataset.index, "allowReplace", !nodePool.config.allowReplace))
                "Allow Replace"


            button
              className: 'btn btn-default',
              "data-index": i,
              onClick: ((e) => e.preventDefault(); handleNodePoolRemove(e.currentTarget.dataset.index)),
                span className: "fa fa-trash"




    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
      React.createElement ReactFormHelpers.SubmitButton,
        label: 'Create',
        loading: clusterForm.isSubmitting,
        disabled: !clusterForm.isValid
        onSubmit: (() -> handleSubmit(close))

NewCluster = connect(
  (state) ->
    clusterForm:  state.clusterForm
    metaData:     state.metaData

  (dispatch) ->
    handleChange:                 (name, value)         -> dispatch(updateClusterForm(name, value))
    handleAdvancedOptionsToggle:  ()                    -> dispatch(toggleAdvancedOptions())
    handleNodePoolChange:         (index, name, value)  -> dispatch(updateNodePoolForm(index, name, value))
    handleNodePoolAdd:            (defaultAZ)           -> dispatch(addNodePool(defaultAZ))
    handleNodePoolRemove:         (index)               -> dispatch(deleteNodePool(index))
    handleSubmit:                 (callback)            -> dispatch(submitClusterForm(callback))
    handleSSHKeyChange:           (value)               -> dispatch(updateSSHKey(value))
    handleKeyPairChange:          (value)               -> dispatch(updateKeyPair(value))

)(NewCluster)

kubernetes.NewClusterModal = ReactModal.Wrapper('Create Cluster', NewCluster,
  xlarge: true,
  closeButton: false,
  static: true
)
