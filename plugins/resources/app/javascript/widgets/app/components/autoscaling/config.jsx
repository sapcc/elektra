import React from "react"
import { DataTable } from "lib/components/datatable"
import { AutoscalingConfigItem } from "./config_item"

import { parseConfig, generateConfig } from "./helper"
import { t } from "../../utils"

const columns = [
  {
    key: "id",
    label: "Project",
    sortStrategy: "text",
    sortKey: (props) => props.project.name || "",
  },
  { key: "config", label: "Configuration" },
  { key: "ajax_indicator", label: "" },
]

export default class AutoscalingConfig extends React.Component {
  state = {
    currentFullResource: "",
    editValues: null,
    isSubmitting: false,
  }

  handleSelect(fullResource) {
    this.setState({
      ...this.state,
      currentFullResource: fullResource,
      editValues: null,
      isSubmitting: false,
    })
  }

  startEditing() {
    const [srvType, resName] = this.state.currentFullResource.split("/")
    const assetType = `project-quota:${srvType}:${resName}`

    const { projectConfigs } = this.props
    const editValues = {}
    for (const projectID in projectConfigs) {
      const parsed = parseConfig(
        projectConfigs[projectID].data[assetType],
        assetType
      )
      if (!parsed.custom) {
        editValues[projectID] = parsed.value === null ? "" : parsed.value
      }
    }

    this.setState({
      ...this.state,
      editValues,
    })
  }

  handleEditValue(projectID, newValue) {
    //input sanitizing: only allow positive integer values
    newValue = newValue.replace(/[^0-9]+/, "")
    //input sanitizing: do not allow values above 90%
    if (parseInt(newValue) > 90) {
      newValue = "90"
    }

    this.setState({
      ...this.state,
      editValues: { ...this.state.editValues, [projectID]: newValue },
    })
  }

  stopEditing() {
    this.setState({
      ...this.state,
      editValues: null,
    })
  }

  save() {
    const [srvType, resName] = this.state.currentFullResource.split("/")
    const assetType = `project-quota:${srvType}:${resName}`

    this.setState({
      ...this.state,
      isSubmitting: true,
    })

    const { projectConfigs } = this.props
    const { editValues } = this.state
    const promises = []
    for (const projectID in projectConfigs) {
      //make sure we don't accidentally overwrite custom configs
      const parsed = parseConfig(
        projectConfigs[projectID].data[assetType],
        assetType
      )
      if (parsed.custom || editValues[projectID] === undefined) {
        continue
      }
      if (editValues[projectID] === "") {
        promises.push(
          this.props.deleteCastellumProjectResource(projectID, assetType)
        )
      } else {
        const cfg = generateConfig(
          parseInt(editValues[projectID], 10),
          null,
          assetType
        )
        promises.push(
          this.props.updateCastellumProjectResource(projectID, assetType, cfg)
        )
      }
    }

    Promise.all(promises).then(() => {
      this.setState({
        ...this.state,
        editValues: null,
        isSubmitting: false,
      })
    })
  }

  renderRows() {
    const { autoscalableSubscopes, projectConfigs } = this.props

    const [srvType, resName] = this.state.currentFullResource.split("/")
    const assetType = `project-quota:${srvType}:${resName}`
    const unitName = this.props.units[assetType]

    const projects = [...autoscalableSubscopes[srvType][resName]]
    projects.sort((a, b) => a.name.localeCompare(b.name))

    const { editValues, isSubmitting } = this.state
    const editorProps = {
      handleEditValue: this.handleEditValue.bind(this),
      isSubmitting,
    }

    return projects.map((project) => (
      <AutoscalingConfigItem
        key={project.id}
        project={project}
        config={projectConfigs[project.id] || { isFetching: true }}
        assetType={assetType}
        unitName={unitName}
        editValue={editValues ? editValues[project.id] : null}
        {...editorProps}
      />
    ))
  }

  render() {
    const { autoscalableSubscopes, projectConfigs, canEdit } = this.props
    const { currentFullResource, editValues, isSubmitting } = this.state

    //assemble options for <select> box
    const options = []
    for (const srvType in autoscalableSubscopes) {
      for (const resName in autoscalableSubscopes[srvType]) {
        const assetType = `project-quota:${srvType}:${resName}`
        let enabledCount = 0
        for (const projectID in projectConfigs) {
          if (projectConfigs[projectID].data == null) {
            enabledCount = "?"
            break
          }
          if (projectConfigs[projectID].data[assetType]) {
            enabledCount++
          }
        }

        const subscopes = autoscalableSubscopes[srvType][resName]
        const category =
          (subscopes.length > 0 && subscopes[0].category) || srvType
        if (subscopes.length > 0) {
          options.push({
            key: `${srvType}/${resName}`,
            label: `${t(category)} > ${t(resName)} (${enabledCount}/${
              subscopes.length
            })`,
          })
        }
      }
    }
    options.sort((a, b) => a.label.localeCompare(b.label))

    return (
      <>
        <div className="row">
          <div className="col-md-8">
            <select
              className="form-control"
              onChange={(e) => this.handleSelect(e.target.value)}
              value={currentFullResource}
            >
              {currentFullResource == "" && (
                <option value="">-- Select a resource --</option>
              )}
              {options.map((opt) => (
                <option key={opt.key} value={opt.key}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>
          {currentFullResource != "" &&
            canEdit &&
            (editValues ? (
              <div className="col-md-4">
                <button
                  className="btn btn-primary"
                  disabled={isSubmitting}
                  onClick={() => this.save()}
                >
                  {isSubmitting ? (
                    <>
                      <span className="spinner" />
                      {" Saving..."}
                    </>
                  ) : (
                    "Save"
                  )}
                </button>{" "}
                <button
                  className="btn btn-link"
                  disabled={isSubmitting}
                  onClick={() => this.stopEditing()}
                >
                  Cancel
                </button>
              </div>
            ) : (
              <div className="col-md-4">
                <button
                  className="btn btn-primary"
                  disabled={isSubmitting}
                  onClick={() => this.startEditing()}
                >
                  Edit this table
                </button>
              </div>
            ))}
        </div>
        {currentFullResource != "" && (
          <DataTable columns={columns}>{this.renderRows()}</DataTable>
        )}
      </>
    )
  }
}
