import React, { useState } from "react"
import { Link } from "react-router-dom"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import ContainerListItem from "./containerListItem"

import {
  Button,
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
  DataGridToolbar,
  Spinner,
} from "juno-ui-components"

const ContainerList = ({ containers, isLoading }) => {
  const [filterTerm, setFilterTerm] = useState(null)

  return (
    <>
      <DataGridToolbar
      //TODO: Later implement the search
      // search={
      //   <SearchField
      //     variant="juno"
      //     onChange={setFilterTerm}
      //     placeholder="Name or Type or Content Type or Status"
      //     text="Searches by Name or Type or Content Type or Status in visible container list only.
      //     Entering a search term will automatically start loading the next pages
      //     and filter the loaded secrets using the search term. Emptying the search
      //     input field will show all currently loaded secrets."
      //   />
      // }
      >
        {policy.isAllowed("keymanagerng:container_create") && (
          <Link to="/containers/newContainer">
            <Button>New Container</Button>
          </Link>
        )}
      </DataGridToolbar>

      {!policy.isAllowed("keymanagerng:container_list") ? (
        <span>You are not allowed to see this page</span>
      ) : isLoading ? (
        <Spinner variant="primary" />
      ) : (
        <DataGrid columns={4} minContentColumns={[3]}>
          <DataGridRow>
            <DataGridHeadCell>Name</DataGridHeadCell>
            <DataGridHeadCell>Type</DataGridHeadCell>
            <DataGridHeadCell>Status</DataGridHeadCell>
            <DataGridHeadCell></DataGridHeadCell>
          </DataGridRow>
          {containers && containers.length > 0 ? (
            containers.map((container, index) => (
              <ContainerListItem key={index} container={container} />
            ))
          ) : (
            <DataGridRow>
              <DataGridCell colSpan={5}>No Containers found.</DataGridCell>
            </DataGridRow>
          )}
        </DataGrid>
      )}
    </>
  )
}

export default ContainerList
