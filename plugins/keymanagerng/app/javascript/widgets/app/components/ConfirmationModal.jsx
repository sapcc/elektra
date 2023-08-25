import React from "react"
import { Modal, Form } from "juno-ui-components"

const ConfirmationModal = ({ text, show, close, onConfirm }) => {
  return (
    <Modal
      title="Warning"
      open={show}
      onCancel={close}
      onConfirm={onConfirm}
      confirmButtonLabel="Remove"
      cancelButtonLabel="Cancel"
    >
      <Form className="form form-horizontal">
        <p>{text}</p>
      </Form>
    </Modal>
  )
}

export default ConfirmationModal
