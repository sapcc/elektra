import React, { useEffect, useState, useCallback, useRef, useMemo } from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import SecretListItem from "./secretListItem"

import {
  Button,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
  DataGridToolbar,
  Spinner,
  Filters,
  SearchInput,
} from "juno-ui-components"

const SecretList = ({ secrets, isLoading, hideActions }) => {
  const [filterTerm, setFilterTerm] = useState(null)

  // const filteredSecrets = useMemo(() => {
  //   if (secrets.length === 0) return []
  //   if (!filterTerm || filterTerm === "") return secrets
  //   return secrets.filter(
  //     (item) =>
  //       (item.name && item.name.indexOf(filterTerm) >= 0) ||
  //       (item.secret_type && item.secret_type.indexOf(filterTerm) >= 0) ||
  //       (item.content_types.default &&
  //         item.content_types.default.indexOf(filterTerm) >= 0) ||
  //       (item.status && item.status.indexOf(filterTerm) >= 0)
  //   )
  // }, [secrets, filterTerm])

  return (
    <>
      {!hideActions && (
        <DataGridToolbar>
          {!hideActions && (
            <Link to="/secrets/newSecret">
              <Button>New Secret</Button>
            </Link>
          )}
        </DataGridToolbar>
      )}
      {!policy.isAllowed("keymanagerng:secret_list") ? (
        <span>You are not allowed to see this page</span>
      ) : isLoading ? (
        <Spinner variant="primary" />
      ) : (
        <DataGrid columns={hideActions ? 4 : 5} minContentColumns={[4]} >
          <DataGridRow>
            {hideActions && <DataGridHeadCell></DataGridHeadCell>}
            <DataGridHeadCell>Name</DataGridHeadCell>
            <DataGridHeadCell>Type</DataGridHeadCell>
            {!hideActions && <DataGridHeadCell>Content Types</DataGridHeadCell>}
            <DataGridHeadCell>Status</DataGridHeadCell>
            {!hideActions && <DataGridHeadCell></DataGridHeadCell>}
          </DataGridRow>
          {secrets && secrets.length > 0 ? (
            secrets.map((secret, index) => (
              <SecretListItem
                key={index}
                secret={secret}
                hideAction={hideActions}
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
