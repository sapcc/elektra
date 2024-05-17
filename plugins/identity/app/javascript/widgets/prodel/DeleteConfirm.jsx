import React from "react"
import { Button } from "juno-ui-components/build/Button"
import { Modal } from "juno-ui-components/build/Modal"

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
        className="tw-z-[1051]"
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
