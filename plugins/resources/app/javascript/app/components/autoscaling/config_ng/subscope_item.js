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
  updateMinFree,
  serviceLabel,
  resourceLabel,
  value,
  minFree,
  originValue,
  originMinFree,
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

  const updateMinFreeValue = React.useCallback((newValue) => {
    //input sanitizing: only allow positive integer values
    newValue = newValue.replace(/[^0-9]+/, "")

    updateMinFree(parseInt(newValue))
  })

  const hasChanged = React.useMemo(() => {
    if (
      (originValue === value ||
        (originValue === null && value === "") ||
        String(originValue) === String(value)) &&
      (originMinFree === minFree ||
        (originMinFree === null && minFree === "") ||
        String(originMinFree) === String(minFree))
    )
      return false
    return true
  }, [value, originValue, minFree, originMinFree])

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
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <div>
                <input
                  disabled={isSaving}
                  type="number"
                  className="form-control"
                  style={{ width: 100, display: "inline" }}
                  value={minFree || ""}
                  onKeyPress={(e) => e.key === "Enter" && save()}
                  onChange={(e) => updateMinFreeValue(e.target.value)}
                />{" "}
                {unit.name || "units"}
              </div>
              <div>
                <input
                  disabled={isSaving}
                  type="number"
                  className="form-control"
                  style={{ width: 100, display: "inline" }}
                  value={value || ""}
                  onKeyPress={(e) => e.key === "Enter" && save()}
                  onChange={(e) => updateValue(e.target.value)}
                />{" "}
                %
              </div>
            </div>

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
            {(value === null || value === "") &&
            (minFree === null || minFree === "") ? (
              "not enabled"
            ) : (
              <span>
                {!Number.isNaN(minFree) && minFree && (
                  <>
                    <strong>{minFree}</strong> {unit.name || "units "}
                  </>
                )}
                {!Number.isNaN(minFree) &&
                  minFree &&
                  !Number.isNaN(value) &&
                  value &&
                  ", "}
                {!Number.isNaN(value) && value && (
                  <>
                    <strong>{value}%</strong>{" "}
                  </>
                )}
                {value === 0 ? `(but at least ${unit.format(1)} free)` : ""}
              </span>
            )}
          </span>
        )}
      </td>

      <td>
        {!custom && (
          <>
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
                bsStyle={value || minFree ? "primary" : "success"}
                onClick={edit}
              >
                {value || minFree ? "Edit" : "Enable"}
              </Button>
            )}
          </>
        )}
      </td>
    </tr>
  )
}

export default AutoscalingConfigSubscopeItem
