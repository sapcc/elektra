import React from "react"
import { Button } from "react-bootstrap"
import { isUnset } from "../helper"
import uniqueId from "lodash/uniqueId"

/**
 * The minFree value allows the user to enter a string such as 2 TiB.
 * We want to display what the user entered, but store the formatted
 * value in the state. For this we use the tempMinFree variable.
 * tempMinFree stores the user input and triggers an update with
 * formatted value in the state.
 * @param {object} props
 * @returns a react component
 */
const MinFreeInput = ({ unit, isDisabled, minFree, onChange, save }) => {
  const [value, setValue] = React.useState()
  // minFree ? unit.format(minFree) : minFree

  const parseAndUpdateMinFree = React.useCallback(
    (newValue) => {
      // update tempMinFree value
      setValue(newValue)

      // if new tempMinFree value is undefined then reset the minFree value in the state.
      if (isUnset(newValue)) {
        onChange(null)
        return
      }

      // if no unit given e.g. count of instances then we extract only the digit from the value.
      if (!unit.name) {
        const count = newValue.toString().replace(/[^0-9]+/, "")
        onChange(parseInt(count))
        return
      }

      // unit is given -> parse value (MiB or GiB etc.)
      let parsedValue = unit.parse(newValue)

      if (parsedValue.error) {
        parsedValue = newValue.toString().replace(/[^0-9]+/, "")
        onChange(parseInt(parsedValue))
        return
      } else {
        onChange(parsedValue)
      }
      //input sanitizing: only allow positive integer values
      //newValue = newValue.replace(/[^0-9]+/, "")
    },
    [unit, onChange, setValue]
  )

  const currentValue = React.useMemo(() => {
    // if minFree is undefined or null return empty string (reset minFree case)
    if (isUnset(minFree)) return ""
    //
    if (value) return value
    return unit.format(minFree)
  }, [value, minFree])

  return (
    <input
      disabled={isDisabled}
      type="text"
      className="form-control"
      style={{ width: 100, display: "inline" }}
      value={currentValue}
      onKeyPress={(e) => e.key === "Enter" && save()}
      onChange={(e) => parseAndUpdateMinFree(e.target.value)}
    />
  )
}

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
  // update the percent value
  const updateValue = React.useCallback(
    (newValue) => {
      //input sanitizing: only allow positive integer values
      newValue = newValue.replace(/[^0-9]+/, "")
      //input sanitizing: do not allow values above 90%
      if (parseInt(newValue) > 90) {
        newValue = "90"
      }

      update(newValue)
      if (isUnset(newValue) || newValue === "") {
        updateMinFree(null)
      }
    },
    [update, updateMinFree]
  )

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

  const atLeastLabel = React.useMemo(() => {
    // value is the percentage value
    if (value !== 0 && isUnset(minFree)) return ""

    // minValue cannot be zero! min RAM or min units must be at least 1.
    // Because scaling down to 0% means at least one unit.
    // unit.format returns a string such as 1 MiB or 1 Gib etc.
    const minValue = unit.format(isUnset(minFree) ? 1 : minFree)
    // minLabel, in case the unit name is not known we add the "units" string
    const unitLabel = unit.name ? "" : "units"
    return ` (but at least ${minValue} ${unitLabel} free)`
  }, [value, minFree, unit])

  return (
    <>
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
              <div style={{ display: "flex" }}>
                <div style={{ width: 150 }}>
                  <input
                    disabled={isSaving}
                    type="number"
                    min="0"
                    className="form-control"
                    style={{ width: 100, display: "inline" }}
                    value={isUnset(value) ? "" : value}
                    onKeyPress={(e) => e.key === "Enter" && save()}
                    onChange={(e) => updateValue(e.target.value)}
                  />{" "}
                  %
                  <br />
                  <span className="small text-muted">
                    leave empty to disable{" "}
                    <a
                      href="#"
                      onClick={(e) => {
                        e.preventDefault()
                        updateValue("")
                        updateMinFree("")
                      }}
                    >
                      clear
                    </a>
                  </span>
                </div>

                <div>
                  min.{" "}
                  <MinFreeInput
                    unit={unit}
                    minFree={minFree}
                    onChange={updateMinFree}
                    isDisabled={isSaving || isUnset(value)}
                    save={save}
                  />{" "}
                  <br />
                  <div className="pull-right">
                    <span className="small text-muted">
                      {minFree} {unit.name ? unit.name : "units"}
                    </span>
                  </div>
                </div>

                <div></div>
              </div>
            </>
          ) : (
            <span onClick={edit} style={{ cursor: "pointer" }}>
              {isUnset(value) ? (
                "not enabled"
              ) : (
                <span>
                  <>
                    <strong>{value}%</strong>{" "}
                  </>
                  {atLeastLabel}
                </span>
              )}
            </span>
          )}
        </td>

        <td>
          {!custom && (
            <div className="display-flex">
              {isSaving ? (
                <Button bsSize="small" bsStyle="primary" disabled={true}>
                  ...saving
                </Button>
              ) : editMode ? (
                <>
                  <Button bsSize="small" bsStyle="default" onClick={cancel}>
                    Cancel
                  </Button>
                  <div className="margin-left">
                    <Button
                      key={uniqueId("button-save-")}
                      bsSize="small"
                      bsStyle="primary"
                      onClick={save}
                      disabled={!hasChanged}
                    >
                      Save
                    </Button>
                  </div>
                </>
              ) : (
                <Button
                  key={uniqueId("button-edit-enable-")}
                  bsSize="small"
                  bsStyle={!isUnset(value) ? "primary" : "success"}
                  onClick={edit}
                >
                  {!isUnset(value) ? "Edit" : "Enable"}
                </Button>
              )}
            </div>
          )}
        </td>
      </tr>
    </>
  )
}

export default AutoscalingConfigSubscopeItem
