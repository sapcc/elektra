import React from "react"
import { policy } from "lib/policy"
import SecretListItem from "./secretListItem"
import HintLoading from "../HintLoading"
import HintNotFound from "../HintNotFound"
import {
  DataGrid,
  DataGridRow,
  DataGridCell,
  DataGridHeadCell,
} from "juno-ui-components"

const SecretList = ({ secrets, isLoading, hideActions }) => {
  return (
    <>
      {!policy.isAllowed("keymanagerng:secret_list") ? (
        <span>You are not allowed to see this page</span>
      ) : (
        <>
          {isLoading && !secrets ? (
            <HintLoading className="tw-mt-4" />
          ) : (
            <DataGrid columns={hideActions ? 4 : 5} minContentColumns={[4]}>
              <DataGridRow>
                {hideActions && <DataGridHeadCell></DataGridHeadCell>}
                <DataGridHeadCell>Name/ID</DataGridHeadCell>
                <DataGridHeadCell>Type</DataGridHeadCell>
                {!hideActions && (
                  <DataGridHeadCell>Content Types</DataGridHeadCell>
                )}
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
                  <DataGridCell colSpan={5}>
                    <HintNotFound text="No Secrets found." />
                  </DataGridCell>
                </DataGridRow>
              )}
            </DataGrid>
          )}
        </>
      )}
    </>
  )
}

export default SecretList
