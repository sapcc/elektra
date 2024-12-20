/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React from "react"

import useStore from "../../store"
import FlagCloud from "../../assets/images/flag_ccloud.svg"

import { Stack } from "@cloudoperators/juno-ui-components"

const RegionSelect = () => {
  const selectRegion = useStore((state) => state.selectRegion)
  const preselectedRegion = useStore((state) => state.preselectedRegion)
  const qaRegionKeys = useStore((state) => state.qaRegionKeys)
  const regionsByContinent = useStore((state) => state.regionsByContinent)

  return (
    <>
      <Stack gap="6" distribution="center">
        {regionsByContinent.map((continent) => (
          <Stack direction="vertical" gap="1.5" className="tw-flex-1" key={continent.name}>
            <div className="tw-text-lg tw-text-theme-high tw-pb-2">{continent.name}</div>
            {continent.regions.map((region) => (
              <Stack
                key={region.key}
                onClick={(e) => {
                  e.preventDefault()
                  selectRegion(region.key)
                }}
                alignment="center"
                className="tw-bg-juno-grey-blue-9 tw-py-3 tw-px-5 tw-cursor-pointer hover:tw-bg-theme-accent hover:tw-text-black"
              >
                <div>
                  <span className="tw-font-bold">{region.key}</span>
                  <br />
                  {region.country}
                </div>
                <div className="tw-ml-auto">{region.icon}</div>
              </Stack>
            ))}
          </Stack>
        ))}
        {preselectedRegion?.startsWith("QA") && (
          <div>
            <div className="tw-text-lg tw-text-theme-high tw-pb-2">QA REGIONS</div>
            <Stack direction="vertical" gap="1.5" className="tw-flex-1">
              {qaRegionKeys.map((region) => (
                <Stack
                  key={region}
                  onClick={(e) => {
                    e.preventDefault()
                    selectRegion(region)
                  }}
                  alignment="center"
                  className="tw-bg-juno-grey-blue-9 tw-py-3 tw-px-5 tw-cursor-pointer tw-hover:bg-theme-accent tw-hover:text-black"
                >
                  <div className="tw-mr-8">
                    <span className="tw-font-bold">{region}</span>
                    <br />
                    QA
                  </div>
                  <div className="tw-ml-auto">
                    <FlagCloud />
                  </div>
                </Stack>
              ))}
            </Stack>
          </div>
        )}
      </Stack>
    </>
  )
}

export default RegionSelect
