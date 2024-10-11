/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React from "react"
import useStore from "../../store"
import { Stack } from "@cloudoperators/juno-ui-components"

const qaRegionStyles = (isSelected) => `
  tw-py-1 
  tw-px-2
  tw-rounded
  ${
    isSelected
      ? "tw-bg-theme-accent tw-text-black tw-cursor-default"
      : "tw-bg-theme-background-lvl-0 tw-text-theme-default"
  }
`

// The QA region selector is only displayed if the preselected region was already a QA region
// The reason is that we don't want to show the QA regions on the landing pages of the productive regions
// so you'll see the QA select only if you started out on a QA region
const WorldMapQASelect = () => {
  const selectedRegion = useStore((state) => state.region)
  const preselectedRegion = useStore((state) => state.preselectedRegion)
  const selectRegion = useStore((state) => state.selectRegion)
  const qaRegionKeys = useStore((state) => state.qaRegionKeys)

  const handleQARegionClick = (e, qaRegion) => {
    e.preventDefault()
    if (qaRegion !== selectedRegion) {
      selectRegion(qaRegion)
    }
  }

  return (
    <>
      {preselectedRegion?.startsWith("QA") && (
        <Stack direction="vertical" gap="2" className="tw-absolute tw-right-0 tw-top-0">
          {qaRegionKeys.map((qaRegion) => (
            <a href="#" key={qaRegion} onClick={(e) => handleQARegionClick(e, qaRegion)}>
              <div className={qaRegionStyles(qaRegion === selectedRegion)}>{qaRegion}</div>
            </a>
          ))}
        </Stack>
      )}
    </>
  )
}

export default WorldMapQASelect
