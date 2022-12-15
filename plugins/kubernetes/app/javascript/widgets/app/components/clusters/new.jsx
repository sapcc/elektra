/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react"
import ReactFormHelpers from "../../lib/form_helpers"
import ReactModal from "../../lib/modal"
import { connect } from "react-redux"

import {
  updateClusterForm,
  addNodePool,
  deleteNodePool,
  updateNodePoolForm,
  submitClusterForm,
  toggleAdvancedOptions,
  updateSSHKey,
  updateKeyPair,
} from "../../actions"

import AdvancedOptions from "./advancedoptions"

let NewCluster = function ({
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
  handleKeyPairChange,
}) {
  let defaultAZName
  let keyPair, flavor
  const onChange = function (e) {
    e.preventDefault()
    return handleChange(e.target.name, e.target.value)
  }

  const cluster = clusterForm.data
  const { spec } = cluster
  if (metaData.loaded) {
    defaultAZName = metaData.availabilityZones[0].name
  }

  return React.createElement(
    "div",
    null,
    React.createElement(
      "div",
      { className: "modal-body" },
      clusterForm.errors ? (
        <div className="alert alert-error">
          <ReactFormHelpers.Errors errors={clusterForm.errors} />
        </div>
      ) : undefined,
      React.createElement(
        "form",
        { className: "form form-horizontal" },
        // Name
        <div className="form-group required string  cluster_name">
          <label
            className="string required col-sm-4 control-label"
            htmlFor="name"
          >
            <abbr title="required">*</abbr> Cluster Name
          </label>
          <div className="col-sm-8">
            <div className="input-wrapper">
              <input
                className="string required form-control"
                type="text"
                name="name"
                placeholder="lower case letters and numbers"
                value={cluster.name || ""}
                onChange={onChange}
              />
            </div>
          </div>
        </div>,

        // Keypair
        React.createElement(
          "div",
          null,
          React.createElement(
            "div",
            { className: "form-group string" },
            <label className="string col-sm-4 control-label" htmlFor="keypair">
              {" "}
              Key Pair
            </label>,
            React.createElement(
              "div",
              { className: "col-sm-8" },
              React.createElement(
                "div",
                { className: "input-wrapper" },
                React.createElement(
                  "select",
                  {
                    name: "keypair",
                    className: "select form-control",
                    value: spec.keyPair || "",
                    onChange(e) {
                      return handleKeyPairChange(e.target.value)
                    },
                  },
                  metaData.keyPairs != null ? (
                    <optgroup label="Choose from personal keys or provide other">
                      <option value="">None</option>
                      {(() => {
                        const result = []
                        for (keyPair of Array.from(metaData.keyPairs)) {
                          result.push(
                            <option
                              value={keyPair.publicKey}
                              key={keyPair.name}
                            >
                              {keyPair.name}
                            </option>
                          )
                        }
                        return result
                      })()}
                      <option value="other">Other</option>
                    </optgroup>
                  ) : (
                    <option value="">Loading...</option>
                  )
                )
              )
            )
          )
        ),

        // SSH Public Key
        metaData.keyPairs != null && spec.keyPair === "other"
          ? React.createElement(
              "div",
              null,
              React.createElement(
                "div",
                { className: "form-group required string" },
                <label
                  className="string required col-sm-4 control-label"
                  htmlFor="sshkey"
                >
                  {" "}
                  SSH Public Key
                </label>,
                React.createElement(
                  "div",
                  { className: "col-sm-8" },
                  React.createElement(
                    "div",
                    { className: "input-wrapper" },
                    React.createElement("textarea", {
                      name: "sshkey",
                      className: "form-control",
                      value: spec.sshPublicKey || "",
                      onChange(e) {
                        return handleSSHKeyChange(e.target.value)
                      },
                      rows: 6,
                      placeholder: "Please paste any valid SSH public key",
                    })
                  )
                )
              )
            )
          : undefined,
        <p className="u-clearfix">
          <a
            className="pull-right"
            onClick={(e) => {
              e.preventDefault()
              return handleAdvancedOptionsToggle()
            }}
            href="#"
          >{`${
            clusterForm.advancedOptionsVisible ? "Hide " : ""
          }Advanced Options`}</a>
        </p>,
        clusterForm.advancedOptionsVisible ? (
          <AdvancedOptions
            clusterForm={clusterForm}
            metaData={metaData}
            info={info}
          />
        ) : undefined
      ),

      // ------- NODEPOOLS --------

      <div className="toolbar">
        <h4>Nodepools</h4>
        <div className="main-buttons">
          {!metaData.loaded ||
          (metaData.error != null && metaData.errorCount <= 20) ? (
            <button className="btn btn-default" disabled="disabled">
              <span className="spinner" />
            </button>
          ) : (
            <button
              className="btn btn-primary"
              onClick={(e) => {
                e.preventDefault()
                return handleNodePoolAdd(defaultAZName)
              }}
            >
              Add Pool
            </button>
          )}
        </div>
      </div>,
      Array.from(cluster.spec.nodePools).map((nodePool, i) =>
        React.createElement(
          "div",
          { className: "nodepool-form", key: `nodepool-${i}` },
          React.createElement(
            "form",
            { className: "form form-inline form-inline-flex" },
            <h5 className="title">{`Pool ${i + 1}:`}</h5>,

            // Nodepool name
            React.createElement(
              "div",
              { className: "form-group required string" },
              <label className="string required control-label" htmlFor="name">
                Name <abbr title="required">*</abbr>
              </label>,
              React.createElement("input", {
                className: "string form-control",
                "data-index": i,
                type: "text",
                name: "name",
                placeholder: "a-z + 0-9",
                value: nodePool.name || "",
                onChange(e) {
                  e.preventDefault
                  return handleNodePoolChange(
                    e.target.dataset.index,
                    e.target.name,
                    e.target.value
                  )
                },
              })
            ),

            // Nodepool flavor
            React.createElement(
              "div",
              { className: "form-group string" },
              <label className="string control-label" htmlFor="flavor">
                Flavor <abbr title="required">*</abbr>
              </label>,
              React.createElement(
                "select",
                {
                  name: "flavor",
                  "data-index": i,
                  className: "select required form-control",
                  value: nodePool.flavor || "",
                  onChange(e) {
                    e.preventDefault
                    return handleNodePoolChange(
                      e.target.dataset.index,
                      e.target.name,
                      e.target.value
                    )
                  },
                },
                (() => {
                  if (
                    !metaData.loaded ||
                    (metaData.error != null && metaData.errorCount <= 20)
                  ) {
                    return <option value="">Loading...</option>
                  } else {
                    if (metaData.flavors != null) {
                      return (() => {
                        const result1 = []
                        for (
                          let f_index = 0;
                          f_index < metaData.flavors.length;
                          f_index++
                        ) {
                          flavor = metaData.flavors[f_index]
                          var flavorMetaData =
                            flavor.ram != null && flavor.vcpus != null
                              ? `(ram: ${flavor.ram}, vcpus: ${flavor.vcpus})`
                              : ""
                          result1.push(
                            <option
                              value={flavor.name}
                              key={f_index}
                            >{`${flavor.name} ${flavorMetaData}`}</option>
                          )
                        }
                        return result1
                      })()
                    }
                  }
                })()
              )
            ),

            // Nodepool Availability Zone
            React.createElement(
              "div",
              { className: "form-group string" },
              <label className="string control-label" htmlFor="az">
                Availability Zone <abbr title="required">*</abbr>
              </label>,
              React.createElement(
                "select",
                {
                  name: "availabilityZone",
                  "data-index": i,
                  className: "string form-control",
                  disabled:
                    nodePool.availabilityZone && !nodePool.new
                      ? "disabled"
                      : undefined,
                  value: nodePool.availabilityZone || defaultAZName,
                  onChange(e) {
                    e.preventDefault
                    return handleNodePoolChange(
                      e.target.dataset.index,
                      e.target.name,
                      e.target.value
                    )
                  },
                },
                (() => {
                  if (
                    !metaData.loaded ||
                    (metaData.error != null && metaData.errorCount <= 20)
                  ) {
                    return <option value="">Loading...</option>
                  } else {
                    if (metaData.availabilityZones != null) {
                      return Array.from(metaData.availabilityZones).map(
                        (az) => (
                          <option
                            value={az.name}
                            key={az.name}
                          >{`${az.name}`}</option>
                        )
                      )
                    }
                  }
                })()
              )
            ),

            // Nodepool size
            React.createElement(
              "div",
              { className: "form-group form-group-size" },
              <label className="string control-label" htmlFor="size">
                Size <abbr title="required">*</abbr>
              </label>,
              React.createElement("input", {
                className: "form-control",
                "data-index": i,
                type: "number",
                name: "size",
                min: "0",
                placeholder: "0",
                value: isNaN(nodePool.size) ? "" : nodePool.size,
                onChange(e) {
                  e.preventDefault
                  return handleNodePoolChange(
                    e.target.dataset.index,
                    e.target.name,
                    parseInt(e.target.value, 10)
                  )
                },
              })
            ),

            // Nodepool Allow Reboot
            React.createElement(
              "div",
              { className: "checkbox inline-checkbox form-group" },
              React.createElement(
                "label",
                { className: "string control-label" },
                React.createElement("input", {
                  type: "checkbox",
                  "data-index": i,
                  checked: nodePool.config.allowReboot,
                  onChange(e) {
                    return handleNodePoolChange(
                      e.target.dataset.index,
                      "allowReboot",
                      !nodePool.config.allowReboot
                    )
                  },
                }),
                "Allow Reboot"
              )
            ),

            // Nodepool Allow Replace
            React.createElement(
              "div",
              { className: "checkbox inline-checkbox form-group" },
              React.createElement(
                "label",
                { className: "string control-label" },
                React.createElement("input", {
                  type: "checkbox",
                  "data-index": i,
                  checked: nodePool.config.allowReplace,
                  onChange(e) {
                    return handleNodePoolChange(
                      e.target.dataset.index,
                      "allowReplace",
                      !nodePool.config.allowReplace
                    )
                  },
                }),
                "Allow Replace"
              )
            ),
            <button
              className="btn btn-default"
              data-index={i}
              onClick={(e) => {
                e.preventDefault()
                return handleNodePoolRemove(e.currentTarget.dataset.index)
              }}
            >
              <span className="fa fa-trash" />
            </button>
          )
        )
      )
    ),
    React.createElement(
      "div",
      { className: "modal-footer" },
      <button
        role="close"
        type="button"
        className="btn btn-default"
        onClick={close}
      >
        Close
      </button>,
      React.createElement(ReactFormHelpers.SubmitButton, {
        label: "Create",
        loading: clusterForm.isSubmitting,
        disabled: !clusterForm.isValid,
        onSubmit() {
          return handleSubmit(close)
        },
      })
    )
  )
}

NewCluster = connect(
  (state) => ({
    clusterForm: state.clusterForm,
    metaData: state.metaData,
  }),
  (dispatch) => ({
    handleChange(name, value) {
      return dispatch(updateClusterForm(name, value))
    },
    handleAdvancedOptionsToggle() {
      return dispatch(toggleAdvancedOptions())
    },
    handleNodePoolChange(index, name, value) {
      return dispatch(updateNodePoolForm(index, name, value))
    },
    handleNodePoolAdd(defaultAZ) {
      return dispatch(addNodePool(defaultAZ))
    },
    handleNodePoolRemove(index) {
      return dispatch(deleteNodePool(index))
    },
    handleSubmit(callback) {
      return dispatch(submitClusterForm(callback))
    },
    handleSSHKeyChange(value) {
      return dispatch(updateSSHKey(value))
    },
    handleKeyPairChange(value) {
      return dispatch(updateKeyPair(value))
    },
  })
)(NewCluster)

const NewClusterModal = ReactModal.Wrapper("Create Cluster", NewCluster, {
  xlarge: true,
  closeButton: false,
  static: true,
})

export default NewClusterModal
