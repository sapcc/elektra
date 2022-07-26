import React from "react"
import { Modal, Button, Alert } from "react-bootstrap"
import { useHistory, useParams } from "react-router-dom"
import { useGlobalState, useDispatch } from "../../stateProvider"
import apiClient from "../../lib/apiClient"

const EmptyContainer = ({}) => {
  const { name } = useParams()
  const history = useHistory()
  const [show, setShow] = React.useState(!!name)
  const [confirmation, setConfirmation] = React.useState("")
  const [isEmpting, setIsEmpting] = React.useState(false)
  const [error, setError] = React.useState()
  const containers = useGlobalState("containers")
  const dispatch = useDispatch()

  const container = React.useMemo(() => {
    if (!containers?.items) return
    return containers.items.find((c) => c.name === name)
  }, [containers, name])

  const close = React.useCallback((e) => {
    setShow(false)
  }, [])

  const back = React.useCallback((e) => {
    history.replace("/containers")
  }, [])

  const submit = React.useCallback(
    (e) => {
      if (e && e.preventDefault) e.preventDefault()
      if (!container || container.name !== confirmation) return

      setError(null)
      apiClient
        .osApi("object-store")
        .put(`${container.name}/empty`)
        // reload containers
        .then(() => apiClient.osApi("object-store").get(""))
        .then((items) =>
          Promise.resolve(dispatch({ type: "RECEIVE_CONTAINERS", items }))
        )
        // close modal window
        .then(close)
        .catch((error) => {
          setError(error.message)
        })
    },
    [confirmation, container]
  )

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="lg"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Empty container: {container?.name}
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        {containers.isFetching ? (
          <span>
            <span className="spinner" />
            Loading...
          </span>
        ) : !container ? (
          <span>Container not found!</span>
        ) : (
          <React.Fragment>
            {error && (
              <Alert bsStyle="danger">
                <strong>An error has occurred</strong>
                <p>{error}</p>
              </Alert>
            )}
            {container.count <= 0 ? (
              <Alert bsStyle="warning">
                <strong>Cannot empty</strong>
                <p>The container is already empty.</p>
              </Alert>
            ) : (
              <React.Fragment>
                <div className="bs-callout bs-callout-danger">
                  <span className="fa fa-exclamation-circle" />
                  <strong> Are you sure?</strong> All objects in the container
                  will be deleted. This cannot be undone.
                  <br />
                  <small style={{ marginLeft: 15 }}>
                    Please note: for
                    <strong> dynamic </strong> and
                    <strong> static large objects </strong>only the manifests
                    are deleted. The related segments are not deleted.
                  </small>
                </div>

                <div className="row">
                  <div className="col-md-6">
                    <fieldset>
                      <div className="form-group string required forms_confirm_container_action_name">
                        <label
                          className="control-label string required"
                          htmlFor="confirmation"
                        >
                          <abbr title="required">*</abbr> Type container name to
                          confirm
                        </label>
                        <input
                          className="form-control string required"
                          autoFocus
                          type="text"
                          value={confirmation}
                          name="confirmation"
                          onChange={(e) => setConfirmation(e.target.value)}
                        />
                      </div>
                    </fieldset>
                  </div>
                </div>
              </React.Fragment>
            )}
          </React.Fragment>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Cancel</Button>

        <Button
          bsStyle="primary"
          onClick={submit}
          disabled={!container || container.name !== confirmation}
        >
          {isEmpting ? "Empting..." : "Empty"}
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default EmptyContainer
