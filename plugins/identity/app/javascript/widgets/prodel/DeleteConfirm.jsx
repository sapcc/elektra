import React from "react"
import { Button } from "juno-ui-components/build/Button"
import { Modal } from "juno-ui-components/build/Modal"

//import { Button, Modal } from "juno-ui-components"

function DeleteConfirm(props) {
  const [showModal, setShowModal] = React.useState(false)

  return (
    <>
      <Button
        label="Delete"
        onClick={() => setShowModal(true)}
        variant="primary-danger"
        disabled={props.disabled}
      />
      <Modal
        open={showModal}
        cancelButtonLabel="Cancel"
        confirmButtonLabel="Yes, Proceed"
        onCancel={() => setShowModal(false)}
        onConfirm={() =>
          props.onConfirm() ? props.onConfirm() : setShowModal(false)
        }
      >
        <p>
          Are you sure you want to delete this project? This action cannot be
          undone.
        </p>
      </Modal>
    </>
  )
}

export default DeleteConfirm
