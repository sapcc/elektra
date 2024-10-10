/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useCallback } from "react"

import useStore from "../store"
import CCLogo from "../assets/images/CCloud_Logo_light.svg"
import WorldMap from "../assets/images/map.svg"
import backgroundTop from "../assets/images/background_header.png"

import LoginOverlay from "../components/landingpage/LoginOverlay"
import WorldMapQASelect from "../components/landingpage/WorldMapQASelect"

import { buildDashboardLink } from "../lib/utils"

import { Button, Icon, Stack } from "@cloudoperators/juno-ui-components"

const Home = () => {
  const showLoginOverlay = useStore(
    useCallback((state) => state.showLoginOverlay)
  )
  const selectedDomain = useStore(useCallback((state) => state.domain))
  const deselectDomain = useStore(useCallback((state) => state.deselectDomain))
  const selectedRegion = useStore(useCallback((state) => state.region))
  const selectRegion = useStore(useCallback((state) => state.selectRegion))
  const prodMode = useStore(useCallback((state) => state.prodMode))

  const handleWorldMapClick = (e) => {
    if (e.target.dataset.region) {
      selectRegion(e.target.dataset.region)
      showLoginOverlay()
    }
  }

  const handleHeroButtonClick = () => {
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

  const handleDomainDeselect = (e) => {
    e.preventDefault()
    deselectDomain()
    showLoginOverlay()
  }

  const setHeroButtonText = () => {
    if (selectedRegion && selectedDomain) {
      return `Enter ${selectedDomain}`
    }

    return `Select ${selectedRegion ? "domain" : "region"}`
  }

  return (
    <div className="flex flex-col grow">
      <LoginOverlay />
      <div className="max-w-[1280px] w-full mx-auto pt-8">
        <CCLogo className="mb-4 w-[240px] h-auto" alt="Converged Cloud" />

        <Stack alignment="center">
          <div className="text-xl w-3/5 mr-auto">
            SAP's strategic Infrastructure-as-a-Service (IaaS) stack, optimised
            for SAP solutions, running purely in SAP datacenters.
          </div>
          <Stack direction="vertical" alignment="end" gap="1">
            <Button
              icon={selectedDomain ? "openInBrowser" : "place"}
              variant="primary"
              title={
                selectedDomain
                  ? `Enter ${selectedDomain}`
                  : "Select region/domain"
              }
              className="whitespace-nowrap py-1.5 px-3"
              onClick={handleHeroButtonClick}
            >
              {setHeroButtonText()}
            </Button>
            {selectedDomain && (
              <a
                href="#"
                onClick={handleDomainDeselect}
                className="text-theme-default text-sm underline inline-flex items-center"
              >
                <Icon icon="place" size="16" className="mr-1" />
                Wrong domain?
              </a>
            )}
          </Stack>
        </Stack>
      </div>
      <div
        className="bg-top bg-no-repeat mt-8 pb-12 grow"
        style={{
          backgroundImage: `url('${
            new URL(backgroundTop, import.meta.url).href
          }')`,
        }}
      >
        <div className="max-w-[1280px] w-full mx-auto relative">
          <WorldMapQASelect />
          <WorldMap
            className="worldmap w-[90%] h-auto mx-auto"
            onClick={handleWorldMapClick}
            data-selected-region={selectedRegion}
          />
        </div>
      </div>
    </div>
  )
}

export default Home
