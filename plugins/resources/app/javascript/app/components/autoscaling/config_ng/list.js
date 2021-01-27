import { Table, FormControl, Row, Col } from "react-bootstrap"
import Item from "./list_item"
import Subscopes from "./subscopes"

/**
 * Autoscaling Config Next Generation (ng)
 * Instead of making the settings per subscope for all projects, the next generation
 * sets autoscaling per project and the associated subscopes.
 * @param {map} props
 */
const AutoscalingConfigNg = ({
  autoscalableSubscopes,
  projectConfigs,
  units,
  deleteCastellumProjectResource,
  updateCastellumProjectResource,
  canEdit,
}) => {
  const [selectedProjectId, setSelectedProjectId] = React.useState(null)
  const [projectSearchTerm, setProjectSearchTerm] = React.useState("")
  const [editMode, setEditMode] = React.useState(false)

  // transform autoscalableSubscopes and projectConfig to a map
  // projectID: {id,name,subscopes: {service,resource,serviceLabel,resourceLabel,unitName, data} }
  const projectsSettings = React.useMemo(() => {
    const projectItems = {}

    // for all services
    for (let service in autoscalableSubscopes) {
      // for all resources in service
      for (let resource in autoscalableSubscopes[service]) {
        const assetType = `project-quota:${service}:${resource}`

        // for all projects in resource
        for (let project of autoscalableSubscopes[service][resource]) {
          projectItems[project.id] = projectItems[project.id] || { ...project }
          projectItems[project.id]["subscopes"] =
            projectItems[project.id]["subscopes"] || []

          projectItems[project.id]["subscopes"].push({
            service,
            resource,
            unitName: units[assetType],
            data: projectConfigs[project.id].data
              ? projectConfigs[project.id].data[assetType]
              : null,
          })
        }
      }
    }

    return projectItems
  }, [autoscalableSubscopes, projectConfigs, units])

  // sort and filter projects
  const filteredProjects = React.useMemo(
    () =>
      Object.values(projectsSettings)
        .sort((p1, p2) => (p1.name < p2.name ? -1 : p1.name > p2.name ? 1 : 0))
        .filter(
          (p) =>
            !projectSearchTerm ||
            projectSearchTerm === "" ||
            p.name.toLowerCase().indexOf(projectSearchTerm.toLowerCase()) >= 0
        ),
    [projectsSettings, projectSearchTerm]
  )

  const selectProject = React.useCallback((projectId, editMode) => {
    setSelectedProjectId(projectId)
    setEditMode(editMode)
  }, [])

  return (
    <>
      <h4>Projects Autoscaling Settings</h4>

      {/* Project Filter  */}
      <Row>
        <Col xs={8}>
          <div className="form-group has-feedback has-floating-placeholder">
            <FormControl
              type="text"
              required
              id="searchterm"
              value={projectSearchTerm}
              onChange={(e) => setProjectSearchTerm(e.target.value)}
            />
            <span className="form-control-feedback">
              {projectSearchTerm && projectSearchTerm !== "" ? (
                <i
                  className="fa fa-times text-muted"
                  style={{ pointerEvents: "auto", cursor: "pointer" }}
                  onClick={() => setProjectSearchTerm("")}
                />
              ) : (
                <i className="fa fa-search text-muted" />
              )}
            </span>
            <label
              className="form-control-floating-placeholder"
              htmlFor="searchterm"
            >
              Filter by name or id
            </label>
          </div>
        </Col>
        <Col xs={4}>
          <p className="form-control-static">
            {" "}
            Showing {filteredProjects.length} of{" "}
            {Object.keys(projectsSettings).length} projects
          </p>
        </Col>
      </Row>

      {/* Projects List */}
      <Table hover>
        <tbody>
          {filteredProjects.map((project) => (
            <Item
              canEdit={canEdit}
              active={selectedProjectId === project?.id}
              onClick={({ editMode }) => selectProject(project.id, editMode)}
              key={project.id}
              project={project}
            />
          ))}
        </tbody>
      </Table>

      {/* Details View */}
      {canEdit && ( //selectedProjectId &&
        <Subscopes
          editMode={editMode}
          project={projectsSettings[selectedProjectId]}
          open={!!selectedProjectId}
          updateConfig={updateCastellumProjectResource}
          deleteConfig={deleteCastellumProjectResource}
          onClose={() => setSelectedProjectId(null)}
        />
      )}
    </>
  )
}

export default AutoscalingConfigNg
