import React, { useState, useEffect } from "react"
import ContainerList from "./containerList"
import Pagination from "../Pagination"
import { getContainers } from "../../containerActions"
import { useQuery } from "@tanstack/react-query"
import {
  Container,
  IntroBox,
  SearchInput,
  DataGridToolbar,
  ButtonRow,
  Button,
  Stack,
  Spinner,
} from "juno-ui-components"
import { Link } from "react-router-dom"
import { useMessageStore } from "messages-provider"
import { parseError } from "../../helpers"
import useContainersSearch from "../../hooks/useContainersSearch"

const ITEMS_PER_PAGE = 20

const Containers = () => {
  const addMessage = useMessageStore((state) => state.addMessage)
  const [currentPage, setCurrentPage] = useState(1)
  const [searchTerm, setSearchTerm] = useState("")
  const [paginationOptions, setPaginationOptions] = useState({
    limit: ITEMS_PER_PAGE,
    offset: 0,
  })
  const search = useContainersSearch({ text: searchTerm })
  const { isLoading, isFetching, data, error } = useQuery(
    ["containers", paginationOptions],
    getContainers,
    {}
  )

  // dispatch error with useEffect because error variable will first set once all retries did not succeed
  useEffect(() => {
    if (error) {
      addMessage({
        variant: "error",
        text: parseError(error),
      })
    }
  }, [error])

  const onPaginationChanged = (page) => {
    // todo check if page < 0
    setCurrentPage(page)
    const newOffset = (page - 1) * ITEMS_PER_PAGE
    setPaginationOptions({ ...paginationOptions, offset: newOffset })
  }

  const onChangeInput = (event) => {
    setSearchTerm(event.target.value)
  }

  const onSearchCancel = () => {
    search.cancel()
  }

  const onClear = () => {
    search.cancel()
    setSearchTerm("")
  }

  return (
    <Container py px={false}>
      <IntroBox>
        <p>
          The secrets resource is the heart of the Barbican service. It provides
          access to the secret/keying material stored in the system. Barbican
          supports the secure storage of data for various content types. For
          more information, visit the&nbsp;
          <a href="http://developer.openstack.org/api-guide/key-manager/secrets.html">
            Barbican OpenStack documentation.
          </a>
        </p>
      </IntroBox>
      <DataGridToolbar
        search={
          <Stack alignment="center">
            <SearchInput
              placeholder="Search by name or ID"
              onChange={onChangeInput}
              onClear={onClear}
            />
            {search.isFetching && (
              <>
                <Button
                  label="Cancel fetching..."
                  onClick={onSearchCancel}
                  progress
                  progressLabel="Cancel fetching..."
                  variant="subdued"
                />
                <Spinner variant="primary" />
              </>
            )}
          </Stack>
        }
      >
        <ButtonRow>
          {policy.isAllowed("keymanagerng:container_create") && (
            <Link to="/containers/newContainer">
              <Button>New Container</Button>
            </Link>
          )}
        </ButtonRow>
      </DataGridToolbar>
      <ContainerList
        containers={
          search.isFiltering ? search.displayResults : data?.containers
        }
        isLoading={isLoading}
      />
      {!search.isFiltering && data?.containers?.length > 0 && (
        <Pagination
          count={data?.total}
          limit={ITEMS_PER_PAGE}
          onChanged={onPaginationChanged}
          isFetching={isFetching || data?.containers?.length === 0}
          disabled={error}
          currentPage={currentPage}
        />
      )}
    </Container>
  )
}

export default Containers
