import React, { useCallback, useRef, useEffect, useState } from "react"
import { deleteSecret } from "../../secretActions"
import { Link, useHistory } from "react-router-dom"
import { policy } from "lib/policy"
import {
  Badge,
  ButtonRow,
  Icon,
  DataGridRow,
  DataGridCell,
  Message,
  Checkbox,
  Modal,
  Form,
} from "juno-ui-components"
import { getSecretUuid } from "../../../lib/secretHelper"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import HintLoading from "../HintLoading"
import ConfirmationModal from "../ConfirmationModal"
import { useMessageStore } from "messages-provider"
import useStore from "../../store"

const SecretListItem = ({ secret, hideAction }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const { push } = useHistory()
  const secretUuid = getSecretUuid(secret)
  const queryClient = useQueryClient()
  const addMessage = useMessageStore((state) => state.addMessage)
  const [show, setShow] = useState(true)

  const { isLoading, isError, error, data, isSuccess, mutate } = useMutation(
    deleteSecret,
    100,
    secretUuid
  )
  const showNewSecret = useStore(useCallback((state) => state.showNewSecret))

  const handleDelete = () => {
    return (
      <ConfirmationModal
        text="Are you sure that you want to delete this secret?"
        show={show}
        close={close}
        onConfirm={() => {
          return mutate(
            {
              id: secretUuid,
            },
            {
              onSuccess: () => {
                //TODO: Confirm remove modal
                queryClient.invalidateQueries("secrets")
                addMessage({
                  variant: "success",
                  text: `The secret ${secretUuid} is successfully deleted.`,
                })
              },
              onError: (error) => {
                addMessage({
                  variant: "error",
                  text: error.data.error,
                })
              },
            }
          )
        }}
      />
    )
  }

  const handleSecretSelected = (oEvent) => {}

  return isLoading && !data ? (
    <HintLoading />
  ) : (
    <DataGridRow>
      {hideAction && (
        <DataGridCell>
          <Checkbox onChange={(oEvent) => handleSecretSelected(oEvent)} />
        </DataGridCell>
      )}
      <DataGridCell>
        <Link
          className="tw-break-all"
          to={`/secrets/${secretUuid}/show`}
          onClick={(event) => showNewSecret && event.preventDefault()}
        >
          {secret.name || secretUuid}
        </Link>
        <div>
          <Badge className="tw-text-xs">{secretUuid}</Badge>
        </div>
      </DataGridCell>
      <DataGridCell>{secret.secret_type}</DataGridCell>
      {!hideAction && (
        <DataGridCell>{secret?.content_types?.default}</DataGridCell>
      )}
      <DataGridCell>{secret.status}</DataGridCell>
      {!hideAction && (
        <DataGridCell nowrap>
          <ButtonRow>
            {policy.isAllowed("keymanagerng:secret_delete") && (
              <Icon
                icon="deleteForever"
                onClick={() => handleDelete(secretUuid)}
              />
            )}
          </ButtonRow>
          {/* <Modal
            title="Warning"
            open={show}
            onCancel={close}
            onConfirm={onConfirm}
            confirmButtonLabel="Save"
            cancelButtonLabel="Cancel"
          >
            <Form className="form form-horizontal">
              <p>
                ` Are you sure you want to delete the secret ${secretUuid}?`
              </p>
            </Form>
          </Modal> */}
        </DataGridCell>
      )}
    </DataGridRow>
  )
}

export default SecretListItem
