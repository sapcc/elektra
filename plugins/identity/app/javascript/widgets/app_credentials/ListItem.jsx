import React, { useEffect } from "react"
import { DataGridRow, DataGridCell, ButtonRow, Icon, Modal } from "@cloudoperators/juno-ui-components"

const ListItem = ({ item, index, handleDelete }) => {
  const [confirmDelete, setConfirmDelete] = React.useState(false)
  const close = () => {
    setConfirmDelete(false)
  }
  return (
    <>
      <DataGridRow key={index}>
        <DataGridCell>{!item.name ? "-" : item.name}</DataGridCell>
        <DataGridCell>{!item.description ? "-" : item.description}</DataGridCell>
        <DataGridCell>
          {!item.expires_at
            ? "Unlimited"
            : new Date(item.expires_at).toLocaleDateString("en-US", {
                month: "long",
                day: "numeric",
                year: "numeric",
              })}
        </DataGridCell>
        <DataGridCell>
          <ButtonRow>
            <Icon icon="deleteForever" onClick={() => setConfirmDelete(true)} />
          </ButtonRow>
        </DataGridCell>
      </DataGridRow>

      <Modal
        title="Warning"
        open={confirmDelete}
        cancelButtonLabel="Cancel"
        confirmButtonLabel="Delete"
        confirmButtonIcon="warning"
        onCancel={close}
        onConfirm={handleDelete}
      >
        <p>
          Are you sure you want to delete application credential <strong>{item.name}</strong>?
        </p>
      </Modal>
    </>
  )
}

export default ListItem
