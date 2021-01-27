import { Button } from "react-bootstrap"

/**
 * Resource scope entry
 * @param {map} props
 */
const AutoscalingConfigSubscopeItem = ({
  save,
  edit,
  cancel,
  update,
  serviceLabel,
  resourceLabel,
  value,
  originValue,
  unit,
  custom,
  error,
  isSaving,
  editMode,
}) => {
  const updateValue = React.useCallback((newValue) => {
    //input sanitizing: only allow positive integer values
    newValue = newValue.replace(/[^0-9]+/, "")
    //input sanitizing: do not allow values above 90%
    if (parseInt(newValue) > 90) {
      newValue = "90"
    }

    update(newValue)
  })

  const hasChanged = React.useMemo(() => {
    if (
      originValue === value ||
      (originValue === null && value === "") ||
      String(originValue) === String(value)
    )
      return false
    return true
  }, [value, originValue])

  return (
    <tr>
      <td className="text-nobreak">
        {resourceLabel}
        <br />
        <span className="small text-muted">{serviceLabel}</span>
      </td>
      <td>
        {error && (
          <>
            <span className="text-danger">{error}</span>
            <br />
          </>
        )}
        {custom ? (
          <em>Custom configuration (applied via API)</em>
        ) : editMode ? (
          <>
            <input
              disabled={isSaving}
              type="number"
              className="form-control"
              style={{ width: "auto", display: "inline" }}
              value={value || ""}
              onKeyPress={(e) => e.key === "Enter" && save()}
              onChange={(e) => updateValue(e.target.value)}
            />{" "}
            % free quota
            <br />
            <span className="small text-muted">
              leave empty to disable{" "}
              <a
                href="#"
                onClick={(e) => {
                  e.preventDefault()
                  updateValue("")
                }}
              >
                clear
              </a>
            </span>
          </>
        ) : (
          <span onClick={edit} style={{ cursor: "pointer" }}>
            {value === null || value === "" ? (
              "not enabled"
            ) : (
              <span>
                <strong>{value}%</strong> free quota{" "}
                {value === 0 ? `(but at least ${unit.format(1)} free)` : ""}
              </span>
            )}
          </span>
        )}
      </td>
      <td>
        {isSaving ? (
          <Button bsSize="small" bsStyle="primary" disabled={true}>
            ...saving
          </Button>
        ) : editMode ? (
          <Button
            bsSize="small"
            bsStyle={hasChanged ? "primary" : "default"}
            onClick={hasChanged ? save : cancel}
          >
            {hasChanged ? "Save" : "Cancel"}
          </Button>
        ) : (
          <Button
            bsSize="small"
            bsStyle={value ? "primary" : "success"}
            onClick={edit}
          >
            {value ? "Edit" : "Enable"}
          </Button>
        )}
      </td>
    </tr>
  )
}

export default AutoscalingConfigSubscopeItem
