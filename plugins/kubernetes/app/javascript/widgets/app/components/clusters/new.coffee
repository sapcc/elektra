import "core/components/form_helpers.coffee"
import "core/components/modal"
import "./advancedoptions.coffee"
import { connect } from "react-redux"

import { 
  updateClusterForm, 
  addNodePool, 
  deleteNodePool, 
  updateNodePoolForm, 
  submitClusterForm,  
  toggleAdvancedOptions, 
  updateSSHKey, 
  updateKeyPair  
} from "../../actions"

import AdvancedOptions from "./advancedoptions.coffee"

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

  React.createElement 'div',  null,
    React.createElement 'div',  className: 'modal-body',
      if clusterForm.errors
        React.createElement 'div',  className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: clusterForm.errors

      React.createElement 'form',  className: 'form form-horizontal',
        # Name
        React.createElement 'div',  className: "form-group required string  cluster_name" ,
          React.createElement 'label',  className: "string required col-sm-4 control-label", htmlFor: "name",
            React.createElement 'abbr',  title: "required", '*'
            ' Cluster Name'
          React.createElement 'div',  className: "col-sm-8",
            React.createElement 'div',  className: "input-wrapper",
              React.createElement 'input', 
                className: "string required form-control",
                type: "text",
                name: "name",
                placeholder: "lower case letters and numbers",
                value: cluster.name || '',
                onChange: onChange


        # Keypair
        React.createElement 'div',  null,
          React.createElement 'div',  className: "form-group string" ,
            React.createElement 'label',  className: "string col-sm-4 control-label", htmlFor: "keypair",
              ' Key Pair'
            React.createElement 'div',  className: "col-sm-8",
              React.createElement 'div',  className: "input-wrapper",
                React.createElement 'select', 
                  name: "keypair",
                  className: "select form-control",
                  value: (spec.keyPair || ''),
                  onChange: ((e) -> handleKeyPairChange(e.target.value)),

                    if metaData.keyPairs?
                      React.createElement 'optgroup',  label: "Choose from personal keys or provide other",
                        React.createElement 'option',  value: '', "None"

                        for keyPair in metaData.keyPairs
                          React.createElement 'option',  value: keyPair.publicKey, key: keyPair.name, keyPair.name

                        React.createElement 'option',  value: 'other', "Other"
                    else
                      React.createElement 'option',  value: '', "Loading..."

        # SSH Public Key
        if metaData.keyPairs? && spec.keyPair == 'other'
          React.createElement 'div',  null,
            React.createElement 'div',  className: "form-group required string" ,
              React.createElement 'label',  className: "string required col-sm-4 control-label", htmlFor: "sshkey",
                ' SSH Public Key'
              React.createElement 'div',  className: "col-sm-8",
                React.createElement 'div',  className: "input-wrapper",
                  React.createElement 'textarea', 
                    name: "sshkey",
                    className: "form-control",
                    value: (spec.sshPublicKey || ''),
                    onChange: ((e) -> handleSSHKeyChange(e.target.value)),
                    rows: 6,
                    placeholder: 'Please paste any valid SSH public key'


        React.createElement 'p', className: 'u-clearfix',
          React.createElement 'a', className: 'pull-right', onClick: ((e) => e.preventDefault(); handleAdvancedOptionsToggle()), href: '#',
            "#{if clusterForm.advancedOptionsVisible then 'Hide ' else ''}Advanced Options"

        if clusterForm.advancedOptionsVisible
            React.createElement AdvancedOptions, clusterForm: clusterForm, metaData: metaData, info: info,



      # ------- NODEPOOLS --------


      React.createElement 'div',  className: 'toolbar',
        React.createElement 'h4',  null, "Nodepools"
        React.createElement 'div',  className: 'main-buttons',
          if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
            React.createElement 'button',  className: 'btn btn-default', disabled: 'disabled',
              React.createElement 'span',  className: 'spinner'
          else
            React.createElement 'button',  className: 'btn btn-primary', onClick: ((e) => e.preventDefault(); handleNodePoolAdd(defaultAZName)),
              'Add Pool'


      for nodePool, i in cluster.spec.nodePools

        React.createElement 'div',  className: 'nodepool-form', key: "nodepool-#{i}",
          React.createElement 'form',  className: 'form form-inline form-inline-flex',
            React.createElement 'h5',  className: 'title', "Pool #{i+1}:"

            # Nodepool name
            React.createElement 'div',  className: "form-group required string" ,
              React.createElement 'label',  className: "string required control-label", htmlFor: "name",
                'Name '
                React.createElement 'abbr',  title: "required", '*'

              React.createElement 'input', 
                className: "string form-control",
                "data-index": i,
                type: "text",
                name: "name",
                placeholder: "a-z + 0-9",
                value: nodePool.name || '',
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value))


            # Nodepool flavor
            React.createElement 'div',  className: "form-group string" ,
              React.createElement 'label',  className: "string control-label", htmlFor: "flavor",
                'Flavor '
                React.createElement 'abbr',  title: "required", '*'

              React.createElement 'select', 
                name: "flavor",
                "data-index": i,
                className: "select required form-control",
                value: (nodePool.flavor || ''),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                  if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
                    React.createElement 'option',  value: '', 'Loading...'
                  else
                    if metaData.flavors?
                      for flavor, f_index in metaData.flavors
                        flavorMetaData = if flavor.ram? && flavor.vcpus? then "(ram: #{flavor.ram}, vcpus: #{flavor.vcpus})" else ""
                        React.createElement 'option',  value: flavor.name, key: f_index, "#{flavor.name} #{flavorMetaData}"


            # Nodepool Availability Zone
            React.createElement 'div',  className: "form-group string" ,
              React.createElement 'label',  className: "string control-label", htmlFor: "az",
                'Availability Zone '
                React.createElement 'abbr',  title: "required", '*'


              React.createElement 'select', 
                name: "availabilityZone",
                "data-index": i,
                className: "string form-control",
                disabled: 'disabled' if nodePool.availabilityZone && !nodePool.new,
                value: (nodePool.availabilityZone || defaultAZName),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                  if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
                    React.createElement 'option',  value: '', 'Loading...'
                  else
                    if metaData.availabilityZones?
                      for az in metaData.availabilityZones
                        React.createElement 'option',  value: az.name, key: az.name, "#{az.name}"


            # Nodepool size
            React.createElement 'div',  className: "form-group form-group-size" ,
              React.createElement 'label',  className: "string control-label", htmlFor: "size",
                'Size '
                React.createElement 'abbr',  title: "required", '*'

              React.createElement 'input', 
                className: "form-control",
                "data-index": i,
                type: "number",
                name: "size",
                min: "0",
                placeholder: "0",
                value: (if isNaN(nodePool.size) then '' else nodePool.size),
                onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, parseInt(e.target.value, 10)))


            # Nodepool Allow Reboot
            React.createElement 'div',  className: "checkbox inline-checkbox form-group" ,
              React.createElement 'label',  className: "string control-label",
                React.createElement 'input',  
                  type: "checkbox", 
                  "data-index": i, 
                  checked: (nodePool.config.allowReboot), 
                  onChange: ((e) -> handleNodePoolChange(e.target.dataset.index, "allowReboot", !nodePool.config.allowReboot))
                "Allow Reboot"

            # Nodepool Allow Replace
            React.createElement 'div',  className: "checkbox inline-checkbox form-group" ,
              React.createElement 'label',  className: "string control-label",
                React.createElement 'input',  
                  type: "checkbox", 
                  "data-index": i, 
                  checked: (nodePool.config.allowReplace),
                  onChange: ((e) -> handleNodePoolChange(e.target.dataset.index, "allowReplace", !nodePool.config.allowReplace))
                "Allow Replace"


            React.createElement 'button', 
              className: 'btn btn-default',
              "data-index": i,
              onClick: ((e) => e.preventDefault(); handleNodePoolRemove(e.currentTarget.dataset.index)),
                React.createElement 'span',  className: "fa fa-trash"




    React.createElement 'div',  className: 'modal-footer',
      React.createElement 'button',  role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'
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

NewClusterModal = ReactModal.Wrapper('Create Cluster', NewCluster,
  xlarge: true,
  closeButton: false,
  static: true
)

export default NewClusterModal