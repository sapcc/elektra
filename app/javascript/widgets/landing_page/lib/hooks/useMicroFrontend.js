/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React from "react"
import useDynamicScript from "./useDynamicScript"

/**
 * IMPORTANT!!!
 * THIS HOOK DOES NOT WORK! The current version of CRA uses webpack 4.
 * To get this hook to work we need to wait until CRA is switched to webpack 5.
 * Workaround: use the "useMicroFrontendWidget" hook instead.
 */

/**
 * Connect dynamically a remote container.
 * @see https://webpack.js.org/concepts/module-federation/#motivation
 * @param {string} scope library name in remote container
 * @param {string} module exposed module in remote container
 */
function loadComponent(scope, module) {
  return async () => {
    // Initializes the shared scope. Fills it with known provided modules from this build and all remotes
    await __webpack_init_sharing__("default")

    const container = window[scope] // or get the container somewhere else

    if (!container) return null
    try {
      // Initialize the container, it may provide shared modules
      await container.init(__webpack_share_scopes__.default)
    } catch (e) {
      if (e.message.indexOf("already been initialized") < 0)
        console.info("ERROR", e)
    }
    const factory = await window[scope].get(module)
    const Module = factory()
    return Module
  }
}

const Widget = ({ url, name, componentName, ...props }) => {
  const { ready, failed } = useDynamicScript({ url })

  if (!ready) {
    return <span>Loading dynamic script: {url}</span>
  }

  if (failed) {
    return <span>Failed to load dynamic script: {url}</span>
  }

  const Component = React.lazy(loadComponent(name, componentName))

  return (
    <React.Suspense fallback="Loading Widget...">
      <Component {...props} />
    </React.Suspense>
  )
}

export const MicroFrontendComponent = (url, componentName) => {
  const [scope, module] = componentName.split("/")

  return (props) => (
    <Widget url={url} name={scope} componentName={`./${module}`} {...props} />
  )
}

export const useMicroFrontend = MicroFrontendComponent
