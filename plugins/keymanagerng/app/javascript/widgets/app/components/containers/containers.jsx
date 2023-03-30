import React, { useState } from "react"
import ContainerList from "./containerList"
import Pagination from "../Pagination"
import { getContainers } from "../../containerActions"
import { useQuery } from "@tanstack/react-query"
import HintLoading from "../HintLoading"
import { Message, Container } from "juno-ui-components"

const ITEMS_PER_PAGE = 20

const Containers = () => {
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
    ["containers", paginationOptions],
    getContainers,
    {}
  )

  return isLoading && !data ? (
    <Container py px={false}>
      <HintLoading text="Loading containers..." />
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
        <Container py px={false}>
          <ContainerList containers={data?.containers} />
          <Pagination
            count={data?.total}
            limit={ITEMS_PER_PAGE}
            onChanged={onPaginationChanged}
            isFetching={isLoading}
            disabled={error}
            currentPage={currentPage}
          />
        </Container>
      )}
    </>
  )
}

export default Containers
