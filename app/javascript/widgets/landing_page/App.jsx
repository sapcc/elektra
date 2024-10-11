/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useEffect } from "react"
import PropTypes from "prop-types"
import PageFooter from "./components/layout/PageFooter"
import PageHead from "./components/layout/PageHead"
import Home from "./pages/home"
import styles from "./styles.scss?inline"
import useStore from "./store"
import { AppShellProvider } from "@cloudoperators/juno-ui-components"

const App = ({ region, domain, prodmode, hideDocs, hideSupport }) => {
  const loginOverlayVisible = useStore((state) => state.loginOverlayVisible)
  const selectRegion = useStore((state) => state.selectRegion)
  const setPreselectedRegion = useStore((state) => state.setPreselectedRegion)
  const selectDomain = useStore((state) => state.selectDomain)
  const setProdMode = useStore((state) => state.setProdMode)
  const setHideDocs = useStore((state) => state.setHideDocs)
  const setHideSupport = useStore((state) => state.setHideSupport)

  useEffect(() => {
    if (region) {
      selectRegion(region.toUpperCase())
      setPreselectedRegion(region.toUpperCase())
    }
    if (domain) {
      selectDomain(domain.toUpperCase())
    }
    setHideDocs(hideDocs === "true" || hideDocs === true)
    setHideSupport(hideSupport === "true" || hideSupport === true)
    setProdMode(prodmode === "true" || prodmode === true)
  }, [])

  return (
    // use custom style cache to avoid conflicts with other apps
    <div className={`tw-flex tw-flex-col tw-h-full ${loginOverlayVisible ? "tw-overflow-hidden tw-h-full" : ""}`}>
      <div className="tw-flex tw-flex-col tw-grow">
        <PageHead />

        <Home />
        {hideSupport !== "true" && hideSupport !== true && <PageFooter />}
      </div>
    </div>
  )
}

App.propTypes = {
  region: PropTypes.string,
  domain: PropTypes.string,
  prodmode: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  hideDocs: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  hideSupport: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
}

const StyledApp = (props = {}) => {
  return (
    <AppShellProvider>
      {/* load styles inside the shadow dom */}
      <style>{styles}</style>
      <App {...props} />
    </AppShellProvider>
  )
}

export default StyledApp
