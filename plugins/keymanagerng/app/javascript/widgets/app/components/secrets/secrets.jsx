import React, { useState } from "react"
import SecretList from "./secretList"
import Pagination from "../Pagination"
import { getSecrets } from "../../secretActions"
import { useQuery } from "@tanstack/react-query"
import HintLoading from "../HintLoading"
import { Message, Container } from "juno-ui-components"

const ITEMS_PER_PAGE = 20

const Secrets = () => {
  const [currentPage, setCurrentPage] = useState(1)
  const [paginationOptions, setPaginationOptions] = useState({
    limit: ITEMS_PER_PAGE,
    offset: 0,
  })

  const onPaginationChanged = (page) => {
    // todo check if page < 0
    setCurrentPage(page)
    const newOffset = (page - 1) * ITEMS_PER_PAGE
    setPaginationOptions({ ...paginationOptions, offset: newOffset })
  }

  const { isLoading, isError, data, error } = useQuery(
    ["secrets", paginationOptions],
    getSecrets,
    {}
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
        <>
          <SecretList
            secrets={data?.secrets}
          />
          <Pagination
            count={data?.total}
            limit={ITEMS_PER_PAGE}
            onChanged={onPaginationChanged}
            isFetching={isLoading}
            disabled={error}
            currentPage={currentPage}
          />
        </>
      )}
    </>
  )
}

export default Secrets
