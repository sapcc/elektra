import React, { useEffect, useState } from "react"
import SecretList from "./secretList"
import Pagination from "../Pagination"
import { fetchSecrets } from "../../secretActions"
import { useGlobalState } from "../StateProvider"

const ITEMS_PER_PAGE = 10

const Secrets = () => {
  const [{ secrets: secretsState }, dispatch] = useGlobalState()
  const [paginationOptions, setPaginationOptions] = useState({
    limit: ITEMS_PER_PAGE,
    offset: 0,
  })

  const onPaginationChanged = (offset) => {
    console.log("offset: ", offset)
    setPaginationOptions({ ...paginationOptions, offset: offset })
  }

  useEffect(() => {
    //Reload secrets while pagination and after create and delete a secret
    if (!paginationOptions) return
    loadSecrets()
  }, [paginationOptions])

  const loadSecrets = () => {
    dispatch({ type: "REQUEST_SECRETS" })
    fetchSecrets(paginationOptions)
      .then((data) => {
        console.log("dispatch:", data)
        dispatch({
          type: "RECEIVE_SECRETS",
          secrets: data.secrets,
          totalNumOfSecrets: data.total,
          paginationOptions: paginationOptions,
        })
      })
      .catch((error) =>
        dispatch({ type: "REQUEST_SECRETS_FAILURE", error: error.message })
      )
  }

  return (
    <>
      <SecretList />
      <Pagination
        count={secretsState.totalNumOfSecrets}
        limit={ITEMS_PER_PAGE}
        onChanged={onPaginationChanged}
        isFetching={secretsState.isFetching}
        disabled={secretsState.error}
      />
    </>
  )
}

export default Secrets
