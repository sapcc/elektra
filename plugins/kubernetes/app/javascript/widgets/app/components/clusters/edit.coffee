import "core/components/form_helpers.coffee"
import "./advancedoptions.coffee"
import "core/components/modal"

import { connect } from "react-redux"
import { 
  updateClusterForm, 
  closeClusterForm, 
  addNodePool, 
  deleteNodePool, 
  updateNodePoolForm, 
  submitClusterForm, 
  requestDeleteCluster,  
  toggleAdvancedOptions, 
  updateSSHKey, 
  updateKeyPair 
} from "../../actions"

import AdvancedOptions from "./advancedoptions.coffee"

class EditCluster extends React.Component 
  # find size status for pool with given name
  nodePoolStatusSize: (cluster, poolName) ->
    pool = (cluster.status.nodePools.filter (i) -> i.name is poolName)[0]
    if pool?
      return pool.size
    else
      # if pool can't be found for some reason, err on the side of caution and pretend size is not zero so it won't get deleted by accident
      return 1


  render: ->
    {close, clusterForm, metaData, info, handleSubmit, handleFormClose, handleChange, handleNodePoolChange, handleNodePoolAdd, handleNodePoolRemove, handleClusterDelete, handleAdvancedOptionsToggle, handleSSHKeyChange, handleKeyPairChange} = @props
    cluster = clusterForm.data
    spec    = cluster.spec

    React.createElement 'div', null,
      React.createElement 'div', className: 'modal-body',
        if clusterForm.errors
          React.createElement 'div', className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: clusterForm.errors

        React.createElement 'form', className: 'form form-horizontal',
          # Name
          React.createElement 'div', className: "form-group string  cluster_name" ,
            React.createElement 'label', className: "string col-sm-4 control-label", htmlFor: "name",
              'Cluster Name'
            React.createElement 'div', className: "col-sm-8",
              React.createElement 'div', className: "input-wrapper",
                React.createElement 'input',
                  className: "string form-control disabled",
                  disabled: 'disabled',
                  type: "text",
                  name: "name",
                  value: cluster.name || ''



          # Keypair
          React.createElement 'div', null,
            React.createElement 'div', className: "form-group required string" ,
              React.createElement 'label', className: "string required col-sm-4 control-label", htmlFor: "keypair",
                ' Key Pair'
              React.createElement 'div', className: "col-sm-8",
                React.createElement 'div', className: "input-wrapper",
                  React.createElement 'select',
                    name: "keypair",
                    className: "select form-control",
                    value: (spec.keyPair || ''),
                    onChange: ((e) -> handleKeyPairChange(e.target.value)),

                      if metaData.keyPairs?
                        React.createElement 'optgroup', label: "Choose from personal keys or provide other",
                          React.createElement 'option', value: '', "None"

                          for keyPair in metaData.keyPairs
                            React.createElement 'option', value: keyPair.publicKey, key: keyPair.name, keyPair.name

                          React.createElement 'option', value: 'other', "Other"
                      else
                        React.createElement 'option', value: '', "Loading..."

          # SSH Public Key
          if metaData.keyPairs? && spec.keyPair == 'other'
            React.createElement 'div', null,
              React.createElement 'div', className: "form-group string" ,
                React.createElement 'label', className: "string required col-sm-4 control-label", htmlFor: "sshkey",
                  ' SSH Public Key'
                React.createElement 'div', className: "col-sm-8",
                  React.createElement 'div', className: "input-wrapper",
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
              React.createElement AdvancedOptions, clusterForm: clusterForm, metaData: metaData, info: info, edit: true


        # ------- NODEPOOLS --------

        React.createElement 'div', className: 'toolbar',
          React.createElement 'h4', null, "Nodepools"
          React.createElement 'div', className: 'main-buttons',
            if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
              React.createElement 'button', className: 'btn btn-default', disabled: 'disabled',
                React.createElement 'span', className: 'spinner'
            else
              defaultAZName = metaData.availabilityZones[0].name
              React.createElement 'button', className: 'btn btn-primary', onClick: ((e) => e.preventDefault(); handleNodePoolAdd(defaultAZName)),
                'Add Pool'

        for nodePool, index in cluster.spec.nodePools
          poolStatusSize = @nodePoolStatusSize(cluster, nodePool.name)

          React.createElement 'div', className: 'nodepool-form', key: "nodepool-#{index}",
            React.createElement 'form', className: 'form form-inline form-inline-flex',
              React.createElement 'h5', className: 'title', "Pool #{index+1}:"
              # Nodepool name
              React.createElement 'div', className: "form-group required string" ,
                React.createElement 'label', className: "string required control-label", htmlFor: "name",
                  'Name '
                  React.createElement 'abbr', title: "required", '*'


                React.createElement 'input',
                  className: "string form-control",
                  "data-index": index,
                  disabled: 'disabled' if nodePool.name && !nodePool.new,
                  type: "text",
                  name: "name",
                  placeholder: "a-z + 0-9",
                  value: nodePool.name || '',
                  onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value))


              # Nodepool flavor
              React.createElement 'div', className: "form-group string" ,
                React.createElement 'label', className: "string control-label", htmlFor: "flavor",
                  'Flavor '
                  React.createElement 'abbr', title: "required", '*'


                React.createElement 'select',
                  name: "flavor",
                  "data-index": index,
                  className: "string form-control",
                  disabled: 'disabled' if nodePool.flavor && !nodePool.new,
                  value: (nodePool.flavor || ''),
                  onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                    if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
                      React.createElement 'option', value: '', 'Loading...'
                    else
                      if metaData.flavors?
                        for flavor, f_index in metaData.flavors
                          flavorMetaData = if flavor.ram? && flavor.vcpus? then "(ram: #{flavor.ram}, vcpus: #{flavor.vcpus})" else ""
                          React.createElement 'option', value: flavor.name, key: f_index, "#{flavor.name} #{flavorMetaData}"


              # Nodepool availability zone
              React.createElement 'div', className: "form-group string" ,
                React.createElement 'label', className: "string control-label", htmlFor: "az",
                  'Availability Zone '
                  React.createElement 'abbr', title: "required", '*'


                React.createElement 'select',
                  name: "availabilityZone",
                  "data-index": index,
                  className: "string form-control",
                  disabled: 'disabled' if nodePool.availabilityZone && !nodePool.new,
                  value: (nodePool.availabilityZone || ''),
                  onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, e.target.value)),

                    if !metaData.loaded || (metaData.error? && metaData.errorCount <= 20)
                      React.createElement 'option', value: '', 'Loading...'
                    else
                      if metaData.availabilityZones?
                        for az in metaData.availabilityZones
                          React.createElement 'option', value: az.name, key: az.name, "#{az.name}"

              
              # Nodepool size
              React.createElement 'div', className: "form-group string form-group-size" ,
                React.createElement 'label', className: "string control-label", htmlFor: "size",
                  'Size '
                  React.createElement 'abbr', title: "required", '*'

                React.createElement 'input',
                  className: "string form-control",
                  "data-index": index,
                  type: "number",
                  name: "size",
                  min: "0",
                  placeholder: "0",
                  value: (if isNaN(nodePool.size) then '' else nodePool.size),
                  onChange: ((e) -> e.preventDefault; handleNodePoolChange(e.target.dataset.index, e.target.name, parseInt(e.target.value, 10)))

              
              # Nodepool Allow Reboot
              React.createElement 'div', className: "checkbox inline-checkbox form-group" ,
                React.createElement 'label', className: "string control-label",
                  React.createElement 'input', 
                    type: "checkbox", 
                    "data-index": index, 
                    checked: (nodePool.config.allowReboot), 
                    onChange: ((e) -> handleNodePoolChange(e.target.dataset.index, "allowReboot", e.target.checked))
                  "Allow Reboot"

              # Nodepool Allow Replace
              React.createElement 'div', className: "checkbox inline-checkbox form-group" ,
                React.createElement 'label', className: "string control-label",
                  React.createElement 'input', 
                    type: "checkbox", 
                    "data-index": index, 
                    checked: (nodePool.config.allowReplace),
                    onChange: ((e) -> handleNodePoolChange(e.target.dataset.index, "allowReplace", e.target.checked))
                  "Allow Replace"


              React.createElement 'button',
                className: 'btn btn-default',
                "data-index": index,
                disabled: 'disabled' if !nodePool.new && (nodePool.size > 0 || poolStatusSize > 0),
                onClick: ((e) -> e.preventDefault(); handleNodePoolRemove(e.currentTarget.dataset.index)),
                  React.createElement 'span', className: "fa #{if nodePool.new || (nodePool.size == 0 && poolStatusSize == 0) then 'fa-trash' else 'fa-lock'}"





      React.createElement 'div', className: 'modal-footer',
        React.createElement 'button', className: 'btn btn-default hover-danger pull-left btn-icon-text', onClick: ((e) -> e.preventDefault(); close(); handleClusterDelete(cluster.name)),
          React.createElement 'i', className: 'fa fa-fw fa-trash-o'
          'Delete Cluster'

        React.createElement 'button', role: 'close', type: 'button', className: 'btn btn-default', onClick: ((e) -> e.preventDefault(); close(); handleFormClose()), 'Close'
        React.createElement ReactFormHelpers.SubmitButton,
          label: 'Update',
          loading: clusterForm.isSubmitting,
          disabled: !(clusterForm.isValid && clusterForm.updatePending)
          onSubmit: (() -> handleSubmit(close))


EditCluster = connect(
  (state) ->
    clusterForm: state.clusterForm
    metaData: state.metaData

  (dispatch) ->
    handleChange:               (name, value)         -> dispatch(updateClusterForm(name, value))
    handleAdvancedOptionsToggle:()                    -> dispatch(toggleAdvancedOptions())
    handleNodePoolChange:       (index, name, value)  -> dispatch(updateNodePoolForm(index, name, value))
    handleNodePoolAdd:          (defaultAZ)           -> dispatch(addNodePool(defaultAZ))
    handleNodePoolRemove:       (index)               -> dispatch(deleteNodePool(index))
    handleFormClose:            ()                    -> dispatch(closeClusterForm())
    handleSubmit:               (callback)            -> dispatch(submitClusterForm(callback))
    handleClusterDelete:        (clusterName)         -> dispatch(requestDeleteCluster(clusterName))
    handleSSHKeyChange:         (value)               -> dispatch(updateSSHKey(value))
    handleKeyPairChange:        (value)               -> dispatch(updateKeyPair(value))




)(EditCluster)

EditClusterModal = ReactModal.Wrapper('Edit Cluster', EditCluster,
  xlarge: true,
  closeButton: false,
  static: true
)

export default EditClusterModal
