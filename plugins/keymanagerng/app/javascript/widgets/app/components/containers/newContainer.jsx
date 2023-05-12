import React, { useCallback, useEffect } from "react"
import { Panel } from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { useActions, MessagesProvider } from "messages-provider"
import useStore from "../../store"
import NewContainerForm from "./newContainerForm"

const NewContainer = () => {
  const location = useLocation()
  const history = useHistory()
  const { addMessage } = useActions()
  const setShowNewContainer = useStore(
    useCallback((state) => state.setShowNewContainer)
  )
  const showNewContainer = useStore(
    useCallback((state) => state.showNewContainer)
  )

  const close = useCallback(() => {
    setShowNewContainer(false)
    history.replace(location.pathname.replace("/newContainer", "")),
      [history, location]
  }, [])

  const onSuccessfullyCloseForm = useCallback((containerUuid) => {
    close()
    addMessage({
      variant: "success",
      text: `The container ${containerUuid} is successfully created.`,
    })
  }, [])

  useEffect(() => {
    setShowNewContainer(true)
  }, [])

  return (
    <Panel
      opened={showNewContainer}
      onClose={close}
      heading="New Container"
      size="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <MessagesProvider>
        <NewContainerForm
          onSuccessfullyCloseForm={onSuccessfullyCloseForm}
          onClose={close}
        />
      </MessagesProvider>
    </Panel>
  )
}
export default NewContainer
