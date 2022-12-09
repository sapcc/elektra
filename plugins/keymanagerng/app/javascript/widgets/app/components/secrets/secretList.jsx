import React, { useEffect, useState, useCallback, useRef, useMemo } from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import SecretListItem from "./secretListItem"
import { useGlobalState } from "../StateProvider"
import { deleteSecret } from "../../secretActions"
import { getSecretUuid } from "../../../lib/secretHelper"
// import { QueryClient, QueryClientProvider } from "react-query"

import {
  Button,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
  DataGridToolbar,
  Spinner,
} from "juno-ui-components"

const SecretList = () => {
  const [filterTerm, setFilterTerm] = useState(null)
  const [{ secrets: secretsState }, dispatch] = useGlobalState()
  const mounted = useRef(false)

  useEffect(() => {
    mounted.current = true
    return () => (mounted.current = false)
  }, [])

  // useEffect(() => {
  //   //Initial load
  //   if (secretsState.loaded || secretsState.isFetching) return
  //   loadSecrets()
  // }, [dispatch])

  // const handleDelete = useCallback(
  //   (id) => {
  //     dispatch({ type: "REQUEST_DELETE_SECRETS", id })
  //     deleteSecret(id)
  //       .then(() => {
  //         return mounted.current && dispatch({ type: "DELETE_SECRETS", id })
  //       })
  //       .catch(
  //         (error) =>
  //           mounted.current &&
  //           dispatch({
  //             type: "DELETE_SECRETS_FAILURE",
  //             id,
  //             error: error.message,
  //           })
  //       )
  //   },
  //   [dispatch]
  // )

  const filteredSecrets = useMemo(() => {
    if (!secretsState.items || secretsState.items.length === 0) return []
    if (!filterTerm || filterTerm === "") return secretsState.items
    return secretsState.items.filter(
      (item) =>
        (item.name && item.name.indexOf(filterTerm) >= 0) ||
        (item.secret_type && item.secret_type.indexOf(filterTerm) >= 0) ||
        (item.content_types.default &&
          item.content_types.default.indexOf(filterTerm) >= 0) ||
        (item.status && item.status.indexOf(filterTerm) >= 0)
    )
  }, [secretsState.items, filterTerm])

  useEffect(() => {
    console.log("secrets component")
  })

  console.log("totalSecrets: ", secretsState.totalNumOfSecrets)
  console.log("secretState: ", secretsState)
  return (
    <>
      <DataGridToolbar
        search={
          <SearchField
            variant="juno"
            onChange={setFilterTerm}
            placeholder="Name or Type or Content Type or Status"
            text="Searches by Name or Type or Content Type or Status in visible secrets list only.
                Entering a search term will automatically start loading the next pages
                and filter the loaded secrets using the search term. Emptying the search
                input field will show all currently loaded secrets."
          />
        }
      >
        {policy.isAllowed("keymanagerng:secret_create") && (
          <Link to="/secrets/newSecret">
            <Button>New Secret</Button>
          </Link>
        )}
      </DataGridToolbar>

      {!policy.isAllowed("keymanagerng:secret_list") ? (
        <span>You are not allowed to see this page</span>
      ) : secretsState.isFetching ? (
        <Spinner variant="primary" />
      ) : (
        <DataGrid columns={5} minContentColumns={[4]}>
          <DataGridRow>
            <DataGridHeadCell>Name</DataGridHeadCell>
            <DataGridHeadCell>Type</DataGridHeadCell>
            <DataGridHeadCell>Content Types</DataGridHeadCell>
            <DataGridHeadCell>Status</DataGridHeadCell>
            <DataGridHeadCell></DataGridHeadCell>
          </DataGridRow>
          {filteredSecrets && filteredSecrets.length > 0 ? (
            filteredSecrets.map((secret, index) => (
              <SecretListItem
                key={index}
                secret={secret}
              />
            ))
          ) : (
            <DataGridRow>
              <DataGridCell colSpan={5}>No Secrets found.</DataGridCell>
            </DataGridRow>
          )}
        </DataGrid>
      )}
    </>
  )
}

export default SecretList
