/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useMemo } from "react"

import useStore from "../../store"
import { buildDashboardLink } from "../../lib/utils"
import FlagCloud from "../../assets/images/flag_ccloud.svg"

import { Icon, Stack } from "@cloudoperators/juno-ui-components"

const domainCardClasses = `
  tw-group
  tw-relative
  tw-bg-juno-grey-blue-9 
  tw-text-theme-high
  tw-p-4
  tw-block
  tw-min-h-[6.25rem]
  hover:tw-bg-theme-accent
  hover:tw-text-black
`

const iconClasses = `
  tw-absolute 
  tw-bottom-2 
  tw-right-2
`

const DomainSelect = () => {
  const selectedRegionKey = useStore((state) => state.region)
  const regions = useStore((state) => state.regions)
  const domains = useStore((state) => state.domains)
  const prodMode = useStore((state) => state.prodMode)

  const selectedRegion = useMemo(() => {
    return regions[selectedRegionKey]
  }, [selectedRegionKey])

  return (
    <>
      <Stack gap="3" alignment="center">
        {selectedRegion?.icon || <FlagCloud />}
        <div>
          <span className="tw-font-bold">{selectedRegionKey}</span>
          <br />
          {selectedRegion?.country || "QA"}
        </div>
      </Stack>
      <h4 className="tw-text-lg tw-uppercase tw-mt-10 tw-mb-3">General Purpose</h4>
      <div className="tw-grid tw-grid-cols-3 tw-gap-4">
        {domains.general.map((domain) => (
          <a
            href={buildDashboardLink(selectedRegionKey, domain?.name, prodMode)}
            className={domainCardClasses}
            key={domain?.name}
          >
            <h5 className="tw-font-bold tw-pb-1">{domain?.name}</h5>
            <div className="tw-pr-9">{domain?.description}</div>
            <div className={`${iconClasses} tw-opacity-40 tw-block tw-group-hover:hidden`}>
              <Icon icon="autoAwesomeMotion" color="tw-text-theme-high" size="36" />
            </div>
            <div className={`${iconClasses} tw-hidden group-hover:tw-block`}>
              <Icon icon="openInBrowser" color="text-black" size="36" />
            </div>
          </a>
        ))}
      </div>
      <h4 className="tw-text-lg tw-uppercase tw-mt-12 tw-mb-3">Special Purpose</h4>
      <div className="tw-grid tw-grid-cols-6 tw-gap-4">
        {domains.special.map((domain) => (
          <a href={buildDashboardLink(selectedRegionKey, domain, prodMode)} className={domainCardClasses} key={domain}>
            <h5 className="tw-font-bold tw-pb-1">{domain}</h5>
            <div className={`${iconClasses} tw-opacity-40 tw-block group-hover:tw-hidden`}>
              <Icon icon="autoAwesomeMotion" color="tw-text-theme-high" size="36" />
            </div>
            <div className={`${iconClasses} tw-hidden group-hover:tw-block`}>
              <Icon icon="openInBrowser" color="text-black" size="36" />
            </div>
          </a>
        ))}
      </div>
    </>
  )
}

export default DomainSelect
