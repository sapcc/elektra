import { Button, Row } from "react-bootstrap"

/**
 * Config Item
 * It renders a table row
 * | project name/ID | status |
 * Status shows count of enabled subscopes or a "disabled" message.
 * @param {map} props
 */
const AutoscalingConfigNgItem = ({ project, onClick, active, canEdit }) => {
  const subscopes = project?.subscopes || []
  const enabledCount = subscopes.filter((s) => !!s.data).length
  const allCount = subscopes.length
  return (
    <tr
      className={`${canEdit ? "clickable" : ""} ${active ? "active" : ""}`}
      onClick={() => canEdit && onClick({ editMode: false })}
    >
      <td>
        {project.name}
        <br />
        <span className="text-muted small">{project.id}</span>
      </td>
      <td>
        <span className={enabledCount === 0 ? "text-default" : "text-success"}>
          {enabledCount === 0
            ? "Autoscaling not enabled"
            : `${enabledCount} of ${allCount} enabled`}
        </span>
      </td>
      <td className="snug">
        {canEdit && (
          <Button
            bsStyle="primary"
            bsSize="small"
            onClick={(e) => {
              e.stopPropagation()
              onClick({ editMode: true })
            }}
          >
            Edit
          </Button>
        )}
      </td>
    </tr>
  )
}

export default AutoscalingConfigNgItem
