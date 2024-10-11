/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, useEffect } from "react"
import { hashCode } from "../utils"

/**
 * This hook creates and adds a script tag to the wrapper (default head).
 * After the unmount, the script tag is automatically removed.
 * @param {map} props url
 */
const useDynamicScript = ({ url, wrapper, dataset }) => {
  const [ready, setReady] = useState(false)
  const [failed, setFailed] = useState(false)

  useEffect(() => {
    if (!url || !wrapper) return

    setReady(false)
    setFailed(false)

    const elementId = hashCode(url + JSON.stringify(dataset))
    let element = document.getElementById(elementId)

    // prevent to load same script twice
    if (element) {
      // script with this url already exists
      if (element.dataset.loaded) {
        // script already loaded
        setReady(true)
      } else {
        // add onload listener
        element.addEventListener("load", () => {
          setReady(true)
        })
        element.addEventListener("error", () => {
          setFailed(true)
        })
      }
    } else {
      // create a new script tag

      element = document.createElement("script")
      element.id = elementId
      element.src = url
      element.type = "text/javascript"
      element.async = true

      if (dataset) {
        for (let key in dataset) {
          element.setAttribute(key, dataset[key])
        }
      }

      element.onload = () => {
        console.log(`Dynamic Script Loaded: ${url}`)
        setReady(true)
        element.setAttribute("data-loaded", true)
      }

      element.onerror = () => {
        console.error(`Dynamic Script Error: ${url}`)
        setFailed(true)
      }

      wrapper.appendChild(element)

      return () => {
        element.remove()
        console.log(`Dynamic Script Removed: ${url}`)
      }
    }
  }, [url, wrapper])

  return {
    ready,
    failed,
  }
}

export default useDynamicScript
