/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useCallback, useMemo } from "react"

import useStore from "../../store"
import { buildDashboardLink } from "../../lib/utils"
import FlagCloud from "../../assets/images/flag_ccloud.svg"

import { Icon, Stack } from "@cloudoperators/juno-ui-components"

const domainCardClasses = `
  group
  relative
  bg-juno-grey-blue-9 
  text-theme-high
  p-4
  block
  min-h-[6.25rem]
  hover:bg-theme-accent
  hover:text-black
`

const iconClasses = `
  absolute 
  bottom-2 
  right-2
`

const DomainSelect = () => {
  const selectedRegionKey = useStore(useCallback((state) => state.region))
  const regions = useStore(useCallback((state) => state.regions))
  const domains = useStore(useCallback((state) => state.domains))
  const prodMode = useStore(useCallback((state) => state.prodMode))

  const selectedRegion = useMemo(() => {
    return regions[selectedRegionKey]
  }, [selectedRegionKey])

  return (
    <>
      <Stack gap="3" alignment="center">
        {selectedRegion?.icon || <FlagCloud />}
        <div>
          <span className="font-bold">{selectedRegionKey}</span>
          <br />
          {selectedRegion?.country || "QA"}
        </div>
      </Stack>
      <h4 className="text-lg uppercase mt-10 mb-3">General Purpose</h4>
      <div className="grid grid-cols-3 gap-4">
        {domains.general.map((domain) => (
          <a
            href={buildDashboardLink(selectedRegionKey, domain?.name, prodMode)}
            className={domainCardClasses}
            key={domain?.name}
          >
            <h5 className="font-bold pb-1">{domain?.name}</h5>
            <div className="pr-9">{domain?.description}</div>
            <div
              className={`${iconClasses} opacity-40 block group-hover:hidden`}
            >
              <Icon
                icon="autoAwesomeMotion"
                color="text-theme-high"
                size="36"
              />
            </div>
            <div className={`${iconClasses} hidden group-hover:block`}>
              <Icon icon="openInBrowser" color="text-black" size="36" />
            </div>
          </a>
        ))}
      </div>
      <h4 className="text-lg uppercase mt-12 mb-3">Special Purpose</h4>
      <div className="grid grid-cols-6 gap-4">
        {domains.special.map((domain) => (
          <a
            href={buildDashboardLink(selectedRegionKey, domain, prodMode)}
            className={domainCardClasses}
            key={domain}
          >
            <h5 className="font-bold pb-1">{domain}</h5>
            <div
              className={`${iconClasses} opacity-40 block group-hover:hidden`}
            >
              <Icon
                icon="autoAwesomeMotion"
                color="text-theme-high"
                size="36"
              />
            </div>
            <div className={`${iconClasses} hidden group-hover:block`}>
              <Icon icon="openInBrowser" color="text-black" size="36" />
            </div>
          </a>
        ))}
      </div>
    </>
  )
}

export default DomainSelect
