import { Button } from "react-bootstrap";
import { isUnset } from "../helper";

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
  const updateValue = React.useCallback(
    (newValue) => {
      //input sanitizing: only allow positive integer values
      newValue = newValue.replace(/[^0-9]+/, "");
      //input sanitizing: do not allow values above 90%
      if (parseInt(newValue) > 90) {
        newValue = "90";
      }

      update(newValue);
      if (isUnset(newValue) || newValue === "") {
        updateMinFree(null);
      }
    },
    [update, updateMinFree]
  );

  React.useEffect(() => {
    if (!minFree) {
      updateMinFree(null);
      return;
    }

    if (!unit.name) {
      const newValue = minFree.toString().replace(/[^0-9]+/, "");
      updateMinFree(parseInt(newValue));
      return;
    }

    const parsedValue = unit.parse(minFree);
    if (parsedValue.error) {
      const newValue = minFree.toString().replace(/[^0-9]+/, "");
      updateMinFree(parseInt(newValue));
      return;
    } else {
      updateMinFree(parsedValue);
    }
    //input sanitizing: only allow positive integer values
    //newValue = newValue.replace(/[^0-9]+/, "")
  }, [JSON.stringify(unit), minFree]);

  const hasChanged = React.useMemo(() => {
    if (
      (originValue === value ||
        (originValue === null && value === "") ||
        String(originValue) === String(value)) &&
      (originMinFree === minFree ||
        (originMinFree === null && minFree === "") ||
        String(originMinFree) === String(minFree))
    )
      return false;
    return true;
  }, [value, originValue, minFree, originMinFree]);

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
                        e.preventDefault();
                        updateValue("");
                        updateMinFreeValue("");
                      }}
                    >
                      clear
                    </a>
                  </span>
                </div>

                <div>
                  min.{" "}
                  <input
                    disabled={isSaving || isUnset(value)}
                    type="text"
                    className="form-control"
                    style={{ width: 100, display: "inline" }}
                    value={isUnset(minFree) ? "" : minFree}
                    onKeyPress={(e) => e.key === "Enter" && save()}
                    onChange={(e) => updateMinFree(e.target.value)}
                  />{" "}
                  <br />
                  <div className="pull-right">
                    <span className="small text-muted">
                      {minFree} {unit.name ? unit.name : "units"}
                    </span>
                  </div>
                </div>
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
                  {(value === 0 || !isUnset(minFree)) &&
                    ` (but at least ${unit.format(
                      isUnset(minFree) ? 1 : minFree
                    )} ${unit.name ? "" : "units"} free)`}
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
                  bsStyle={!isUnset(value) ? "primary" : "success"}
                  onClick={edit}
                >
                  {!isUnset(value) ? "Edit" : "Enable"}
                </Button>
              )}
            </>
          )}
        </td>
      </tr>
    </>
  );
};

export default AutoscalingConfigSubscopeItem;
