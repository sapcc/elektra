import React, { useEffect, useCallback } from "react"
import { Panel } from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { useActions, MessagesProvider } from "messages-provider"
import useStore from "../../store"
import NewSecretForm from "./newSecretForm"

const NewSecret = () => {
  const location = useLocation()
  const history = useHistory()
  const { addMessage } = useActions()
  const setShowNewSecret = useStore(
    useCallback((state) => state.setShowNewSecret)
  )
  const showNewSecret = useStore(useCallback((state) => state.showNewSecret))
  const close = useCallback(() => {
    setShowNewSecret(false)
    history.replace(location.pathname.replace("/newSecret", "")),
      [history, location]
  }, [])

  const onSuccessfullyCloseForm = useCallback((secretUuid) => {
    close()
    addMessage({
      variant: "success",
      text: `The secret ${secretUuid} is successfully created.`,
    })
  }, [])

  useEffect(() => {
    setShowNewSecret(true)
  }, [])

  return (
    <Panel
      opened={showNewSecret}
      onClose={close}
      heading="New Secret"
      size="large"
    >
      <MessagesProvider>
        <NewSecretForm
          onSuccessfullyCloseForm={onSuccessfullyCloseForm}
          onClose={close}
        />
      </MessagesProvider>
    </Panel>
  )
}
export default NewSecret
