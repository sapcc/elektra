/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useCallback } from "react"
import useStore from "../../store"
import { Stack } from "@cloudoperators/juno-ui-components"

const qaRegionStyles = (isSelected) => `
  py-1 
  px-2
  rounded
  ${
    isSelected
      ? "bg-theme-accent text-black cursor-default"
      : "bg-theme-background-lvl-0 text-theme-default"
  }
`

// The QA region selector is only displayed if the preselected region was already a QA region
// The reason is that we don't want to show the QA regions on the landing pages of the productive regions
// so you'll see the QA select only if you started out on a QA region
const WorldMapQASelect = () => {
  const selectedRegion = useStore(useCallback((state) => state.region))
  const preselectedRegion = useStore(
    useCallback((state) => state.preselectedRegion)
  )
  const selectRegion = useStore(useCallback((state) => state.selectRegion))
  const qaRegionKeys = useStore(useCallback((state) => state.qaRegionKeys))

  const handleQARegionClick = (e, qaRegion) => {
    e.preventDefault()
    if (qaRegion !== selectedRegion) {
      selectRegion(qaRegion)
    }
  }

  return (
    <>
      {preselectedRegion?.startsWith("QA") && (
        <Stack direction="vertical" gap="2" className="absolute right-0 top-0">
          {qaRegionKeys.map((qaRegion) => (
            <a
              href="#"
              key={qaRegion}
              onClick={(e) => handleQARegionClick(e, qaRegion)}
            >
              <div className={qaRegionStyles(qaRegion === selectedRegion)}>
                {qaRegion}
              </div>
            </a>
          ))}
        </Stack>
      )}
    </>
  )
}

export default WorldMapQASelect
