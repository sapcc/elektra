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
  Container,
} from "juno-ui-components"
import { getSecretUuid } from "../../../lib/secretHelper"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import HintLoading from "../HintLoading"
import ConfirmationModal from "../ConfirmationModal"
import { useMessageStore } from "messages-provider"
import useStore from "../../store"

const SecretListItem = ({ secret }) => {
  // manually push a path onto the react router history
  // once we run on react-router-dom v6 this should be replaced with the useNavigate hook, and the push function with a navigate function
  // like this: const navigate = useNavigate(), the use navigate('this/is/the/path') in the onClick handler of the edit button below
  const secretUuid = getSecretUuid(secret)
  const queryClient = useQueryClient()
  const addMessage = useMessageStore((state) => state.addMessage)
  const [show, setShow] = useState(false)

  const { isLoading, data, mutate } = useMutation(deleteSecret, 100, secretUuid)
  const showNewSecret = useStore(useCallback((state) => state.showNewSecret))

  const handleDelete = () => {
    setShow(true)
  }

  const onConfirm = () => {
    return mutate(
      {
        id: secretUuid,
      },
      {
        onSuccess: () => {
          setShow(false)
          queryClient.invalidateQueries("secrets")
          addMessage({
            variant: "success",
            text: `The secret ${secretUuid} is successfully deleted.`,
          })
        },
        onError: (error) => {
          setShow(false)
          addMessage({
            variant: "error",
            text: error.data.error,
          })
        },
      }
    )
  }

  const close = () => {
    setShow(false)
  }
  
  const handleSecretSelected = (oEvent) => {}

  return isLoading && !data ? (
    <DataGridRow>
      <DataGridCell>
        <HintLoading />
      </DataGridCell>
      <DataGridCell></DataGridCell>
      <DataGridCell></DataGridCell>
      <DataGridCell></DataGridCell>
      <DataGridCell></DataGridCell>
    </DataGridRow>
  ) : (
    <>
      <DataGridRow>
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
        <DataGridCell>{secret?.content_types?.default}</DataGridCell>
        <DataGridCell>{secret.status}</DataGridCell>
        <DataGridCell nowrap>
          <ButtonRow>
            {policy.isAllowed("keymanagerng:secret_delete") && (
              <Icon
                icon="deleteForever"
                onClick={() => handleDelete(secretUuid)}
              />
            )}
          </ButtonRow>
        </DataGridCell>
      </DataGridRow>
      <ConfirmationModal
        text={`Are you sure you want to delete the secret ${
          secret.name || secretUuid
        }?`}
        show={show}
        close={close}
        onConfirm={onConfirm}
      />
    </>
  )
}

export default SecretListItem
