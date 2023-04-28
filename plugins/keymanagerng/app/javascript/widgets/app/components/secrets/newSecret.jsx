import React, { useEffect, useState, useCallback, useRef } from "react"
import {
  Modal,
  Form,
  TextInputRow,
  TextareaRow,
  SelectRow,
  SelectOption,
  Message,
  Container,
  Box,
  Panel,
  PanelBody,
  PanelFooter,
  Button,
} from "juno-ui-components"
import { useHistory, useLocation } from "react-router-dom"
import { createSecret } from "../../secretActions"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { useMessageStore, MessagesProvider } from "messages-provider"
import { getSecretUuid } from "../../../lib/secretHelper"
import useStore from "../../store"
import NewSecretForm from "./newSecretForm"

const NewSecret = () => {
  const location = useLocation()
  const history = useHistory()
  const addMessage = useMessageStore((state) => state.addMessage)
  const setShowNewSecret = useStore(
    useCallback((state) => state.setShowNewSecret)
  )
  const showNewSecret = useStore(useCallback((state) => state.showNewSecret))
  const close = useCallback(() => {
    setShowNewSecret(false)
    history.replace(location.pathname.replace("/newSecret", "")), [history, location]
  }, [])

  const onCloseForm = useCallback((secretUuid) => {
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
    <Panel opened={showNewSecret} onClose={close} heading="New Secret" size="large">
      <MessagesProvider>
        <NewSecretForm onCloseForm={onCloseForm}/>
      </MessagesProvider>
    </Panel>
  )
}
export default NewSecret
