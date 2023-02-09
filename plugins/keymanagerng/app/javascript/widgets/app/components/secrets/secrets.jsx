import React, { useState } from "react"
import SecretList from "./secretList"
import Pagination from "../Pagination"
import { getSecrets } from "../../secretActions"
import { useGlobalState } from "../StateProvider"
import { useQuery } from "react-query"
import HintLoading from "../HintLoading"
import { Message, Container } from "juno-ui-components"

const ITEMS_PER_PAGE = 10

const Secrets = () => {
  const [{ secrets: secretsState }, dispatch] = useGlobalState()
  const [paginationOptions, setPaginationOptions] = useState({
    limit: ITEMS_PER_PAGE,
    offset: 0,
  })

  const onPaginationChanged = (offset) => {
    setPaginationOptions({ ...paginationOptions, offset: offset })
  }
  const { isLoading, isError, data, error } = useQuery(
    ["secrets", paginationOptions],
    getSecrets,
    {
      onSuccess: (data) => {
        console.log("SECRETS: ", paginationOptions)
        dispatch({
          type: "RECEIVE_SECRETS",
          secrets: data?.secrets,
          totalNumOfSecrets: data?.total,
          paginationOptions: paginationOptions,
        })
      },
      onError: () => {
        //TODO: Ask why in case of error, here is error null but in line 50 works correct
        console.log("fetchSecrets onError:", error)
        dispatch({ type: "REQUEST_SECRETS_FAILURE", error: error })
      },
    }
  )

  return isLoading && !data ? (
    <Container py px={false}>
      <HintLoading text="Loading secrets..." />
    </Container>
  ) : (
    <>
      {isError ? (
        <Container py px={false}>
          <Message variant="danger">
            {`${error?.statusCode}, ${error?.message}`}
          </Message>
        </Container>
      ) : (
        <SecretList />
      )}
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
