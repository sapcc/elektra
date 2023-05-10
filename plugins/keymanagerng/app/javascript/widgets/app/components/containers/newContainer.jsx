import React, { useState, useCallback, useEffect } from "react"
import {
  Form,
  TextInputRow,
  SelectRow,
  SelectOption,
  Label,
  Panel,
  PanelBody,
  PanelFooter,
  Button,
} from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { createContainer } from "../../containerActions"
import { getSecrets } from "../../secretActions"
import { useMutation, useQueryClient, useQuery } from "@tanstack/react-query"
import CreatableSelect from "react-select/creatable"
import { useMessageStore, Messages, MessagesProvider } from "messages-provider"
import { getContainerUuid } from "../../../lib/containerHelper"
import useStore from "../../store"
import NewContainerForm from "./newContainerForm"


const NewContainer = () => {
  const location = useLocation()
  const history = useHistory()
  const addMessage = useMessageStore((state) => state.addMessage)
  const resetMessages = useMessageStore((state) => state.resetMessages)
  const setShowNewContainer = useStore(
    useCallback((state) => state.setShowNewContainer)
  )
  const showNewContainer = useStore(useCallback((state) => state.showNewContainer))

  const close = useCallback(() => {
    setShowNewContainer(false)
    history.replace(location.pathname.replace("/newContainer", "")), [history, location]
  }, [])

  const onSuccessfullyCloseForm = useCallback((secretUuid) => {
    close()
    addMessage({
      variant: "success",
      text: `The secret ${secretUuid} is successfully created.`,
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
        <NewContainerForm onSuccessfullyCloseForm={onSuccessfullyCloseForm} onClose={close}/>
      </MessagesProvider>
    </Panel>
  )
}
export default NewContainer