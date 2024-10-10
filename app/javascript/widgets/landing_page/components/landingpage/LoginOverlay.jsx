/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useMemo, useCallback } from "react"

import useStore from "../../store"

import { Button, Icon, Stack } from "@cloudoperators/juno-ui-components"

import RegionSelect from "./RegionSelect"
import DomainSelect from "./DomainSelect"

const overlayStyles = (isOpen) => {
  return `
    ${isOpen ? "block" : "hidden"}
    backdrop-blur-xl
    backdrop-saturate-200
    bg-theme-background-lvl-0
    bg-opacity-30
    border
    border-theme-background-lvl-0
    flex
    flex-col
    absolute
    inset-0
    pt-24
    z-[99]
    overflow-y-scroll
    `
}

const tabClasses = (isActive) => {
  return `
    uppercase 
    text-theme-default
    text-xl 
    pb-3 
    px-24 
    -mb-0.5
    ${
      isActive
        ? "cursor-default text-theme-high border-b-3 border-theme-accent"
        : ""
    }
    `
}

const tabLinkClasses = (isActive) => {
  return `
    ${isActive ? "" : "hover:text-theme-accent"}
    `
}

const LoginOverlay = () => {
  const loginOverlayVisible = useStore(
    useCallback((state) => state.loginOverlayVisible)
  )
  const hideLoginOverlay = useStore(
    useCallback((state) => state.hideLoginOverlay)
  )
  const selectedRegion = useStore(useCallback((state) => state.region))
  const deselectRegion = useStore(useCallback((state) => state.deselectRegion))
  const regionKeys = useStore(useCallback((state) => state.regionKeys))
  const qaRegionKeys = useStore(useCallback((state) => state.qaRegionKeys))

  const isValidRegionSelected = useMemo(() => {
    return (
      selectedRegion !== null &&
      (regionKeys.includes(selectedRegion) ||
        qaRegionKeys.includes(selectedRegion))
    )
  }, [selectedRegion])

  return (
    <div className={overlayStyles(loginOverlayVisible)}>
      <div className="w-full max-w-screen-xl mx-auto pb-12">
        <div className="w-full flex items-center justify-end">
          <Icon
            onClick={() => hideLoginOverlay()}
            icon="close"
            color="text-theme-accent"
            size="36"
            className="-mr-12"
          />
        </div>
        <nav className="w-full border-b-2 border-juno-grey-light-8 mb-8">
          <Stack distribution="around">
            <a
              href="#"
              onClick={() => deselectRegion()}
              className={`${tabClasses(
                !isValidRegionSelected
              )} ${tabLinkClasses(!isValidRegionSelected)}`}
            >
              1. Choose your region
            </a>
            <div className={tabClasses(isValidRegionSelected)}>
              2. Choose your domain
            </div>
          </Stack>
        </nav>
        <div className="w-full">
          {isValidRegionSelected ? <DomainSelect /> : <RegionSelect />}
        </div>
      </div>

      <div className="w-full bg-juno-grey-blue-10 mt-auto">
        <Stack
          alignment="center"
          className="documentation-banner max-w-screen-xl mx-auto py-10"
        >
          <div>
            <h5 className="text-3xl">New here?</h5>
            <p>
              Have a look at the <span className="italic">Getting Started</span>{" "}
              section of our documentation
            </p>
          </div>
          <div className="ml-auto pl-8 pr-20">
            <Button
              variant="primary"
              title="Go to documentation"
              href="https://documentation.global.cloud.sap/docs/start-userreg"
              target="_blank"
            >
              <Icon
                icon="openInNew"
                color="text-theme-high"
                className=" mr-2"
              />
              Go to documentation
            </Button>
          </div>
        </Stack>
      </div>
    </div>
  )
}

export default LoginOverlay
