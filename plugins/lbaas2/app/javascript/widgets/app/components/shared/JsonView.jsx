import { useMemo, useEffect } from "react"
import { Modal } from "react-bootstrap"
import "lib/jsoneditor"
import ErrorPage from "../ErrorPage"
import React from "react"

const JsonView = ({
  show,
  close,
  restoreUrl,
  title,
  jsonObject,
  loadObject,
}) => {
  useEffect(() => {
    if (!jsonObject.item) return
    window.init_json_editor()
  }, [jsonObject])

  return useMemo(() => {
    return (
      <Modal
        show={show}
        onHide={close}
        bsSize="large"
        backdrop="static"
        onExited={restoreUrl}
        aria-labelledby="contained-modal-title-lg"
        bsClass="lbaas2 modal"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">{title}</Modal.Title>
        </Modal.Header>

        {jsonObject.error ? (
          <Modal.Body>
            <ErrorPage
              headTitle={title}
              error={jsonObject.error}
              onReload={loadObject}
            />
          </Modal.Body>
        ) : (
          <Modal.Body>
            {jsonObject.isLoading ? (
              <Modal.Body>
                <span className="spinner" />
              </Modal.Body>
            ) : (
              <React.Fragment>
                <div
                  id="jsoneditor"
                  data-mode="view"
                  data-content={JSON.stringify(jsonObject.item)}
                />
              </React.Fragment>
            )}
          </Modal.Body>
        )}
      </Modal>
    )
  }, [show, title, JSON.stringify(jsonObject)])
}

export default JsonView
