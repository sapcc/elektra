/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useCallback } from "react"

import useStore from "../../store"
import FlagCloud from "../../assets/images/flag_ccloud.svg"

import { Stack } from "@cloudoperators/juno-ui-components"

const RegionSelect = () => {
  const selectRegion = useStore(useCallback((state) => state.selectRegion))
  const preselectedRegion = useStore(
    useCallback((state) => state.preselectedRegion)
  )
  const qaRegionKeys = useStore(useCallback((state) => state.qaRegionKeys))
  const regionsByContinent = useStore(
    useCallback((state) => state.regionsByContinent)
  )

  return (
    <>
      <Stack gap="6" distribution="center">
        {regionsByContinent.map((continent) => (
          <Stack
            direction="vertical"
            gap="1.5"
            className="flex-1"
            key={continent.name}
          >
            <div className="text-lg text-theme-high pb-2">{continent.name}</div>
            {continent.regions.map((region) => (
              <Stack
                key={region.key}
                onClick={() => selectRegion(region.key)}
                alignment="center"
                className="bg-juno-grey-blue-9 py-3 px-5 cursor-pointer hover:bg-theme-accent hover:text-black"
              >
                <div>
                  <span className="font-bold">{region.key}</span>
                  <br />
                  {region.country}
                </div>
                <div className="ml-auto">{region.icon}</div>
              </Stack>
            ))}
          </Stack>
        ))}
        {preselectedRegion?.startsWith("QA") && (
          <div>
            <div className="text-lg text-theme-high pb-2">QA REGIONS</div>
            <Stack direction="vertical" gap="1.5" className="flex-1">
              {qaRegionKeys.map((region) => (
                <Stack
                  key={region}
                  onClick={() => selectRegion(region)}
                  alignment="center"
                  className="bg-juno-grey-blue-9 py-3 px-5 cursor-pointer hover:bg-theme-accent hover:text-black"
                >
                  <div className="mr-8">
                    <span className="font-bold">{region}</span>
                    <br />
                    QA
                  </div>
                  <div className="ml-auto">
                    <FlagCloud />
                  </div>
                </Stack>
                // <div
                //   key={region}
                //   onClick={() => selectRegion(region)}
                //   className="font-bold bg-juno-grey-blue-9 py-3 px-5 cursor-pointer hover:bg-theme-accent hover:text-black"
                // >
                //   {region}
                // </div>
              ))}
            </Stack>
          </div>
        )}
      </Stack>
    </>
  )
}

export default RegionSelect
