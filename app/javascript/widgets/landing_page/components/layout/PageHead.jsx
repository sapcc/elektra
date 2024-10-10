/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useCallback } from "react"

import useStore from "../../store"
import { buildDashboardLink, buildPasswordLoginLink } from "../../lib/utils"

import { Button, Stack, PageHeader } from "@cloudoperators/juno-ui-components"

const PageHead = () => {
  const showLoginOverlay = useStore(
    useCallback((state) => state.showLoginOverlay)
  )
  const selectedDomain = useStore(useCallback((state) => state.domain))
  const selectedRegion = useStore(useCallback((state) => state.region))
  const prodMode = useStore(useCallback((state) => state.prodMode))

  const handleLoginButtonClick = () => {
    if (selectedRegion && selectedDomain) {
      window.location.href = buildDashboardLink(
        selectedRegion,
        selectedDomain,
        prodMode
      )
    } else {
      showLoginOverlay()
    }
  }

  return (
    <PageHeader>
      <Stack className="ml-auto" gap="4" alignment="center">
        {selectedDomain === "CC3TEST" && (
          <a
            href={buildPasswordLoginLink(
              selectedRegion,
              selectedDomain,
              prodMode
            )}
            className="text-theme-disabled hover:underline"
          >
            Log in with password
          </a>
        )}
        <Button
          variant="primary"
          size="small"
          icon="manageAccounts"
          title="Log in"
          onClick={handleLoginButtonClick}
        >
          Log in
        </Button>
      </Stack>
    </PageHeader>
  )
}

export default PageHead
