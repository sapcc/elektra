import React from "react"
import { DataGridRow, DataGridCell, ButtonRow, Icon, Modal, Badge, Stack } from "@cloudoperators/juno-ui-components"
import { Link } from "react-router-dom"

const ListItem = ({ item, index, handleDelete }) => {
  const [confirmDelete, setConfirmDelete] = React.useState(false)
  const close = () => {
    setConfirmDelete(false)
  }

  let expired = false
  let expiredDate = null
  if (item.expires_at && item.expires_at !== "Unlimited") {
    const expriresAt = new Date(item.expires_at)
    //console.log("expiresAt", expriresAt)
    const currentDate = new Date()
    //console.log("currentDate", currentDate)
    if (currentDate > expriresAt) {
      expired = true
    }
    expiredDate = expriresAt.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
      year: "numeric",
    })
  } else {
    //console.log("expiresAt is not set or is Unlimited")
    expiredDate = "Unlimited"
  }

  return (
    <>
      <DataGridRow key={index}>
        <DataGridCell>{!item.name ? "-" : <Link to={`/${item.id}/show`}>{item.name}</Link>}</DataGridCell>
        <DataGridCell>{!item.id ? "-" : item.id}</DataGridCell>
        <DataGridCell>{!item.description ? "-" : item.description}</DataGridCell>
        <DataGridCell>
          {expired ? (
            <Stack direction="horizontal" gap="1">
              <Badge variant="warning" icon="warning">
                Expired/
              </Badge>
              <Badge variant="warning" icon="info">
                {expiredDate}
              </Badge>
            </Stack>
          ) : (
            <Stack direction="horizontal" gap="1">
              <Badge variant="success" icon="success">
                Active
              </Badge>
              <Badge variant="success" icon="info">
                {expiredDate}
              </Badge>
            </Stack>
          )}
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
        confirmButtonIcon="danger"
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
