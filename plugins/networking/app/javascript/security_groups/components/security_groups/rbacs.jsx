import { Modal, Button, Alert } from "react-bootstrap"
import { useParams, useHistory } from "react-router-dom"
import { pluginAjaxHelper } from "ajax_helper"
import React from "react"
const ajaxHelper = pluginAjaxHelper("networking")

const initialState = { items: [] }

function reducer(state, action) {
  switch (action.type) {
    case "request":
      return { ...state, isFetching: true, error: null }
    case "receive":
      return { ...state, isFetching: false, items: action.items }
    case "add": {
      const items = state.items.slice()
      const index = items.findIndex((i) => i.id === action.item.id)
      if (index >= 0) items[index] = action.item
      else items.unshift(action.item)
      return { ...state, items }
    }
    case "remove": {
      const index = state.items.findIndex((i) => i.id === action.item.id)
      if (index < 0) return state
      const items = state.items.slice()
      items.splice(index, 1)
      return { ...state, items }
    }
    case "error":
      return { ...state, error: action.error }
    case "reset_error":
      return { ...state, error: null }
    default:
      throw new Error()
  }
}

const RBACs = ({ securityGroup }) => {
  const { securityGroupId } = useParams()
  const [state, dispatch] = React.useReducer(reducer, initialState)
  const [show, setShow] = React.useState(!!securityGroupId)
  const [newItem, setNewItem] = React.useState()
  const [isCreating, setIsCreating] = React.useState(false)
  const history = useHistory()

  React.useEffect(() => {
    if (!securityGroupId) return
    dispatch({ type: "request" })
    ajaxHelper
      .get(`security-groups/${securityGroupId}/rbacs`)
      .then((response) => {
        dispatch({ type: "receive", items: response.data })
      })
      .catch((error) => {
        const message = error?.response?.data?.errors || error?.message
        dispatch({ type: "error", error: message })
      })
  }, [securityGroupId])

  const add = React.useCallback(() => {
    setIsCreating(true)
    dispatch({ type: "reset_error" })
    ajaxHelper
      .post(`security-groups/${securityGroupId}/rbacs`, {
        target_tenant: newItem,
      })
      .then((response) => {
        dispatch({ type: "add", item: response.data })
        setNewItem("")
      })
      .catch((error) => {
        const message =
          (error.response &&
            error.response.data &&
            error.response.data.errors) ||
          error.message
        dispatch({ type: "error", error: message })
      })
      .finally(() => setIsCreating(false))
  }, [newItem])

  const close = React.useCallback((e) => {
    setShow(false)
  }, [])

  const back = React.useCallback((e) => {
    history.replace("/")
  }, [])

  return (
    <Modal
      show={show}
      onHide={close}
      onExited={back}
      bsSize="large"
      backdrop="static"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Access Control for {securityGroup?.name || securityGroupId}
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        {state.error && (
          <Alert bsStyle="danger">
            {typeof state.error === "string"
              ? state.error
              : Object.keys(state.error).map((key, i) => (
                  <div key={i}>
                    {key}: {state.error[key]}
                  </div>
                ))}
          </Alert>
        )}
        {state.isFetching ? (
          <span>
            <span className="spinner" />
            Loading...
          </span>
        ) : state.items.length === 0 ? (
          <span>No items found!</span>
        ) : (
          <table className="table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Target Project</th>
              </tr>
            </thead>
            <tbody>
              {state.items.map((item, i) => (
                <tr key={i}>
                  <td>{item.id}</td>
                  <td>{item.target_tenant}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <div className="row">
          <div className="col-sm-6" />
          <div className="col-sm-6">
            <div className="pull-right">
              <div className="input-group">
                <input
                  disabled={isCreating}
                  type="text"
                  value={newItem || ""}
                  onChange={(e) => setNewItem(e.target.value)}
                  className="form-control"
                  placeholder="Project ID"
                />
                <div className="input-group-btn">
                  <button
                    disabled={isCreating}
                    type="button"
                    className="btn btn-primary"
                    onClick={add}
                  >
                    {isCreating ? "...Adding" : "Add"}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Close</Button>
      </Modal.Footer>
    </Modal>
  )
}

export default RBACs
