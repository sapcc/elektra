import React from "react"
import { Modal, Button, Alert } from "react-bootstrap"
import { useHistory, useParams } from "react-router-dom"
import useActions from "../../hooks/useActions"
import { useGlobalState } from "../../StateProvider"

const DelteContainer = () => {
  const { name } = useParams()
  const history = useHistory()
  const [show, setShow] = React.useState(!!name)
  const [confirmation, setConfirmation] = React.useState("")
  const [isDeleteing, setIsDeleting] = React.useState(false)
  const [error, setError] = React.useState()
  const containers = useGlobalState("containers")
  const headerRef = React.createRef()
  const confirmationRef = React.createRef()
  const { deleteContainer } = useActions()

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
      setIsDeleting(true)
      deleteContainer(container.name)
        // close modal window
        .then(close)
        .catch((error) => {
          if (error.status === 409)
            setError(
              "Cannot delete container because it contains objects. Please empty it first."
            )
          else setError(error.message)
          setIsDeleting(false)
        })
    },
    [confirmation, container, deleteContainer]
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
          Delete container: <span ref={headerRef}>{container?.name}</span>{" "}
          <small>
            <a
              href="#"
              onClick={(e) => {
                e.preventDefault()
                if (!headerRef.current || !confirmationRef.current) return
                confirmationRef.current.value = headerRef.current.textContent
                setConfirmation(headerRef.current.textContent)
              }}
            >
              <i className="fa fa-clone" />
            </a>
          </small>
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
            {container.count > 0 ? (
              <div className="bs-callout bs-callout-danger">
                <span className="fa fa-exclamation-circle"></span> Cannot delete
                Container contains objects. Please empty it first.
              </div>
            ) : (
              <React.Fragment>
                <div className="bs-callout bs-callout-danger">
                  <span className="fa fa-exclamation-circle" />{" "}
                  <strong>Are you sure?</strong> The container will be deleted.
                  This cannot be undone.
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
                          ref={confirmationRef}
                          className="form-control string required"
                          autoFocus
                          type="text"
                          value={confirmation}
                          name="confirmation"
                          onChange={(e) => setConfirmation(e.target.value)}
                        />
                      </div>
                    </fieldset>

                    {isDeleteing && (
                      <span>
                        Deleting <span className="spinner" />{" "}
                      </span>
                    )}
                  </div>
                </div>
              </React.Fragment>
            )}
          </React.Fragment>
        )}
      </Modal.Body>
      <Modal.Footer>
        {container ? (
          container.count <= 0 ? (
            <React.Fragment>
              <Button onClick={close}>Cancel</Button>

              <Button
                bsStyle="primary"
                onClick={submit}
                disabled={
                  !container || container.name !== confirmation || isDeleteing
                }
              >
                {isDeleteing ? "Deleting..." : "Delete"}
              </Button>
            </React.Fragment>
          ) : (
            <Button onClick={close}>Got it!</Button>
          )
        ) : (
          <Button onClick={close}>Cancel</Button>
        )}
      </Modal.Footer>
    </Modal>
  )
}

export default DelteContainer
