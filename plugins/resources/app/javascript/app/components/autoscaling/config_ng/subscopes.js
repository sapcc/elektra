import { Table, FormControl, Button, Row, Col } from "react-bootstrap"
import SubscopeItem from "./subscope_item"
import { t } from "../../../utils"
import { parseConfig, generateConfig } from "../helper"
import Item from "./list_item"
import Subscopes from "./subscopes"
import { Unit } from "../../../unit"
import resource from "../../domain/resource"

const styles = {
  detailsWrapper: {
    width: "50%",
    maxWidth: 1024,
    height: "100vh",
    position: "fixed",
    top: 0,
    right: 0,
    backgroundColor: "#eee",
    zIndex: 1000,
    boxShadow: "-1px 0 5px grey",
    transition: "0.5s",
  },
  detailsContainer: {
    padding: "15px 20px 10px 15px",
    display: "flex",
    justifyContent: "space-between",
  },
}

/****************************************
 * Details View
 ****************************************/
// array of {service,resource,value,isSaving,editMode,error,parsed}
function subscopesReducer(state, action) {
  switch (action.type) {
    case "init":
      return { ...state, items: action.items }
    case "editAll":
      return {
        ...state,
        items: state.items.map((i) => ({ ...i, error: null, editMode: true })),
      }
    case "updateAll":
      return {
        ...state,
        items: state.items.map((i) => ({ ...i, value: action.value })),
      }

    case "saveAll":
      return {
        ...state,
        items: state.items.map((i) => ({ ...i, isSaving: true, error: null })),
      }

    case "savedAll":
      return {
        ...state,
        items: state.items.map((i) => ({
          ...i,
          isSaving: false,
          editMode: false,
          error: null,
        })),
      }

    case "cancelAll":
      return {
        ...state,
        items: state.items.map((i) => ({
          ...i,
          error: null,
          editMode: false,
          isSaving: false,
          value: i.originValue,
        })),
      }
  }

  const index = state.items.findIndex((i) => i.assetType === action.assetType)
  if (index < 0) return state
  const items = state.items.slice()
  const item = items[index]

  switch (action.type) {
    case "update":
      items[index] = { ...item, value: action.value }
      return { ...state, items }

    case "save":
      items[index] = { ...item, isSaving: true, error: null }
      return { ...state, items }

    case "saved":
      items[index] = { ...item, isSaving: false, editMode: false, error: null }
      return { ...state, items }

    case "error":
      items[index] = { ...item, isSaving: false, error }
      return { ...state, items }

    case "edit":
      items[index] = { ...item, error: null, editMode: true }
      return { ...state, items }

    case "cancel":
      items[index] = {
        ...item,
        error: null,
        editMode: false,
        isSaving: false,
        value: item.originValue,
      }
      return { ...state, items }

    default:
      throw new Error()
  }
}

/**
 * Details View for project resource scopes
 * @param {map} props
 */
const AutoscalingConfigNgSubscopes = ({
  editMode,
  project,
  onClose,
  open,
  updateConfig,
  deleteConfig,
}) => {
  const [height, setHeight] = React.useState(0)
  const [searchTerm, setSearchTerm] = React.useState("")

  React.useEffect(() => {
    const updateHeight = () => setHeight(window.innerHeight)
    const closeOnEscape = (e) => e.key === "Escape" && onClose()
    window.addEventListener("keyup", closeOnEscape)
    window.addEventListener("resize", updateHeight)
    updateHeight()
    return () => {
      window.removeEventListener("resize", updateHeight)
      window.removeEventListener("keyup", closeOnEscape)
    }
  }, [])

  const [subscopesState, dispatch] = React.useReducer(subscopesReducer, {
    items: [],
  })

  const applyToAllRef = React.useRef()

  const initialized = React.useRef(false)

  React.useEffect(() => {
    if (project?.subscopes) {
      dispatch({
        type: "init",
        items: project.subscopes.map((s) => {
          const parsedData = parseConfig(s.data)

          return {
            assetType: `project-quota:${s.service}:${s.resource}`,
            service: s.service,
            resource: s.resource,
            serviceLabel: t(s.category),
            resourceLabel: t(s.resource),
            value: parsedData?.value,
            originValue: parsedData?.value,
            custom: parsedData?.custom,
            unit: new Unit(s.unitName),
            editMode: initialized.current !== project.id && editMode,
          }
        }),
      })
      initialized.current = project.id
    }
  }, [project?.subscopes])

  const submit = React.useCallback(
    (assetType, newValue) => {
      if (!project?.id) return Promise.reject()
      if (newValue === "") {
        return deleteConfig(project.id, assetType)
      } else {
        const newValueInt = parseInt(newValue)
        const cfg = generateConfig(newValueInt)
        return updateConfig(project.id, assetType, cfg)
      }
    },
    [project?.id]
  )

  const save = React.useCallback(
    (assetType) => {
      if (!subscopesState.items)
        return Promise.reject(new Error("no items in subscope state!"))

      const subscope = subscopesState.items.find(
        (s) => s.assetType === assetType
      )

      if (!subscope)
        return Promise.reject(new Error(`subscope ${assetType} not found!`))
      const newValue = subscope.value || ""
      const originValue = subscope.originValue || ""

      if (newValue === originValue) return

      dispatch({ type: "save", assetType })
      submit(assetType, newValue)
        .then(() => dispatch({ type: "saved", assetType }))
        .catch((error) =>
          dispatch({ type: "error", assetType, error: error.message })
        )
    },
    [subscopesState]
  )

  const saveAll = React.useCallback(() => {
    dispatch({ type: "saveAll" })
    const promises = []
    for (let subscope of subscopesState.items) {
      const newValue = subscope.value || ""
      const originValue = subscope.originValue || ""

      if (newValue === originValue) continue

      promises.push(
        submit(subscope.assetType, newValue).catch((error) =>
          dispatch({ type: "error", assetType, error: error.message })
        )
      )
    }
    Promise.all(promises).then(() => dispatch({ type: "savedAll" }))
  }, [subscopesState, dispatch])

  const editAll = React.useCallback(() => dispatch({ type: "editAll" }), [
    dispatch,
  ])

  const cancelAll = React.useCallback(() => dispatch({ type: "cancelAll" }), [
    dispatch,
  ])

  const [top, maxHeight] = React.useMemo(() => [93, height - 93], [height])

  const filteredSubscopes = React.useMemo(() => {
    let items = subscopesState.items || []
    if (searchTerm && searchTerm !== "") {
      items = items.filter(
        (s) =>
          s.serviceLabel &&
          s.resourceLabel &&
          (s.serviceLabel.toLowerCase().indexOf(searchTerm.toLowerCase()) >=
            0 ||
            s.resourceLabel.toLowerCase().indexOf(searchTerm.toLowerCase()) >=
              0)
      )
    }
    return items.sort((a, b) =>
      a.service < b.service ? -1 : a.service > b.service ? 1 : 0
    )
  }, [subscopesState, searchTerm])

  const editModeCount = React.useMemo(
    () => filteredSubscopes.filter((s) => s.editMode).length
  )

  return (
    <div
      style={{
        ...styles.detailsWrapper,
        width: open ? "50%" : 0,
        top,
        height: maxHeight,
      }}
    >
      {project && (
        <>
          <div style={{ ...styles.detailsContainer }}>
            <h4>Autoscaling Settings for {project && project.name}</h4>
            <div></div>
            <div>
              <button
                type="button"
                className="close pull-right"
                style={{ opacity: 1 }}
                aria-label="Close"
                onClick={onClose}
              >
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
          </div>
          <div
            style={{ padding: 15, overflow: "auto", height: maxHeight - 30 }}
          >
            <Row>
              <Col xs={12}>
                <div className="form-group has-feedback has-floating-placeholder">
                  <FormControl
                    type="text"
                    required
                    id="resource-searchterm"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                  />
                  <span className="form-control-feedback">
                    {searchTerm && searchTerm !== "" ? (
                      <i
                        className="fa fa-times text-muted"
                        style={{ pointerEvents: "auto", cursor: "pointer" }}
                        onClick={() => setSearchTerm("")}
                      />
                    ) : (
                      <i className="fa fa-search text-muted" />
                    )}
                  </span>
                  <label
                    className="form-control-floating-placeholder"
                    htmlFor="resource-searchterm"
                  >
                    Filter by resource
                  </label>
                </div>

                <div
                  style={{ display: "flex", justifyContent: "space-between" }}
                >
                  <div className="form-group">
                    {editModeCount === filteredSubscopes.length && (
                      <div className="input-group input-group-sm">
                        <input
                          ref={applyToAllRef}
                          type="number"
                          className="form-control"
                        />
                        <div
                          className="btn input-group-addon bg-success"
                          onClick={(e) =>
                            dispatch({
                              type: "updateAll",
                              value: applyToAllRef.current.value,
                            })
                          }
                        >
                          apply to all
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="clearfix">
                    <div className="pull-right">
                      <Button
                        disabled={editModeCount === filteredSubscopes.length}
                        bsSize="small"
                        bsStyle="warning"
                        onClick={editAll}
                      >
                        Edit All
                      </Button>{" "}
                      <Button
                        disabled={editModeCount === 0}
                        bsSize="small"
                        bsStyle="default"
                        onClick={cancelAll}
                      >
                        Cancel All
                      </Button>{" "}
                      <Button
                        disabled={editModeCount === 0}
                        bsSize="small"
                        bsStyle="primary"
                        onClick={saveAll}
                      >
                        Save All
                      </Button>
                    </div>
                  </div>
                </div>
              </Col>
            </Row>

            <Table responsive hover>
              <thead>
                <tr>
                  <th className="snug">Ressource</th>
                  <th>Status</th>
                  <th className="snug"></th>
                </tr>
              </thead>
              <tbody>
                {filteredSubscopes.map(({ assetType, ...props }, i) => (
                  <SubscopeItem
                    key={i}
                    save={() => save(assetType)}
                    edit={() =>
                      dispatch({
                        type: "edit",
                        assetType: assetType,
                      })
                    }
                    update={(value) =>
                      dispatch({
                        type: "update",
                        assetType: assetType,
                        value,
                      })
                    }
                    cancel={() =>
                      dispatch({
                        type: "cancel",
                        assetType: assetType,
                      })
                    }
                    {...props}
                  />
                ))}
              </tbody>
            </Table>
          </div>
        </>
      )}
    </div>
  )
}

export default AutoscalingConfigNgSubscopes
