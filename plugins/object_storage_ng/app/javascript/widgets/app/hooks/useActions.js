import React from "react"
import { useLocation } from "react-router-dom"
import { useDispatch, useGlobalState } from "../stateProvider"

import { createAjaxHelper } from "lib/ajax_helper"

const useActions = () => {
  const location = useLocation()
  const apiClient = React.useMemo(
    () =>
      createAjaxHelper({
        baseURL: decodeURIComponent(window.location.pathname).replace(
          decodeURIComponent(location.pathname),
          ""
        ),
      }),
    [location.pathname]
  )

  const { capabilities, containers, objects, account } = useGlobalState()
  const dispatch = useDispatch()

  const loadCapabilitiesOnce = React.useCallback(
    (options = {}) => {
      if (capabilities.updatedAt && !options.reload) return

      dispatch({ type: "REQUEST_CAPABILITIES" })
      apiClient
        .osApi("object-store")
        .get("info", { params: { path_prefix: "/" } })
        .then((response) => {
          dispatch({ type: "RECEIVE_CAPABILITIES", data: response.data })
        })
        .catch((error) =>
          dispatch({ type: "RECEIVE_CAPABILITIES_ERROR", error: error.message })
        )
    },
    [dispatch, capabilities.updatedAt]
  )

  const loadAccountMetadataOnce = React.useCallback(
    (options = {}) => {
      if (account.updatedAt && !options.reload) return account.data

      dispatch({ type: "REQUEST_ACCOUNT_METADATA" })
      return apiClient
        .osApi("object-store")
        .head("")
        .then((response) => {
          dispatch({ type: "RECEIVE_ACCOUNT_METADATA", data: response.headers })
          return response.headers
        })
        .catch((error) =>
          dispatch({
            type: "RECEIVE_ACCOUNT_METADATA_ERROR",
            error: error.message,
          })
        )
    },
    [dispatch, account]
  )

  const loadContainersOnce = React.useCallback(
    (options = {}) => {
      if (containers.updatedAt && !options.reload) return Promise.resolve()

      dispatch({ type: "REQUEST_CONTAINERS" })

      return apiClient
        .osApi("object-store")
        .get("")
        .then((response) => {
          dispatch({ type: "RECEIVE_CONTAINERS", items: response.data })
          return response.data
        })
        .catch((error) =>
          dispatch({ type: "RECEIVE_CONTAINERS_ERROR", error: error.message })
        )
    },
    [dispatch, containers.updatedAt]
  )

  const loadContainerObjects = React.useCallback(
    (containerName, options = {}) =>
      apiClient
        .osApi("object-store")
        .get(encodeURIComponent(containerName), { params: options })
        .then((response) => ({
          data: response.data,
          headers: response.headers,
        })),
    [dispatch, objects]
  )

  const loadObjectMetadata = React.useCallback(
    (containerName, name) =>
      apiClient
        .osApi("object-store")
        .head(
          encodeURIComponent(containerName) + "/" + encodeURIComponent(name)
        )
        .then((response) => response.headers),
    []
  )

  const deleteObject = React.useCallback((containerName, name, params = {}) => {
    let query =
      "?" +
      Object.keys(params)
        .map((key) => `${key}=${params[key]}`)
        .join("&")
    return apiClient
      .osApi("object-store")
      .delete(encodeURIComponent(containerName + "/" + name + query))
      .then((response) => response.data)
  }, [])

  const deleteObjects = React.useCallback(
    (containerName, objects) => {
      const bulkDeleteOptions = capabilities?.data?.bulk_delete
      let promises = []

      // Deleting objects can be done in chunks if the API supports bulk delete options
      if (bulkDeleteOptions && bulkDeleteOptions.max_deletes_per_request) {
        // bulk delete!
        const chunkSize = bulkDeleteOptions.max_deletes_per_request
        for (let i = 0; i < objects.length; i += chunkSize) {
          const chunk = objects.slice(i, i + chunkSize)
          const body = chunk
            .map((o) => encodeURIComponent(`${containerName}/${o.name}`))
            .join("\n")
          // collect all delete promises
          promises.push(
            apiClient
              .osApi("object-store")
              .post("", body, {
                params: { "bulk-delete": true },
                headers: { "Content-Type": "text/plain" },
              })
              .then((response) => {
                const data = response.data || {}
                const status = data["Response Status"] || ""
                if (status.indexOf("200") < 0)
                  throw new Error(data["Response Body"])
                else return data
              })
          )
        }
      } else {
        // Delete each object individually
        // collect delete promises
        promises = objects.map((object) =>
          deleteObject(containerName, object.name)
        )
      }
      // Promise.all allows us to delete objects or object chunks in parallel
      return Promise.all(promises)
    },
    [capabilities, deleteObject]
  )

  const deleteContainer = React.useCallback(
    (containerName) =>
      apiClient
        .osApi("object-store")
        .delete(encodeURIComponent(containerName))
        .then(() => {
          dispatch({ type: "REMOVE_CONTAINER", name: containerName })
        }),
    [dispatch]
  )

  const createContainer = React.useCallback(
    (containerName) =>
      apiClient
        .osApi("object-store")
        .put(
          encodeURIComponent(containerName),
          {},
          { headers: { "Content-Length": "0" } }
        )
        .then(() => {
          dispatch({
            type: "RECEIVE_CONTAINER",
            item: {
              name: containerName,
              count: 0,
              bytes: 0,
              last_modified: new Date().toISOString(),
            },
          })
        }),
    [dispatch]
  )

  const createFolder = React.useCallback((containerName, path, name) => {
    let fullPath = path ? path : ""
    if (fullPath.length > 0 && fullPath[fullPath.length - 1] !== "/")
      fullPath += "/"
    fullPath += name + "/"
    const contentType = "application/directory"

    return apiClient
      .osApi("object-store")
      .put(
        encodeURIComponent(containerName + "/" + fullPath),
        {},
        { headers: { "Content-Type": contentType } }
      )
      .then(() => ({
        subdir: fullPath,
      }))
  }, [])

  const loadContainerMetadata = React.useCallback(
    (containerName) => {
      let container = containers.items.find((c) => c.name === containerName)
      if (container && container.metadata)
        return Promise.resolve(container.metadata)

      return apiClient
        .osApi("object-store")
        .head(encodeURIComponent(containerName))
        .then((response) => {
          const metadata = response.headers
          dispatch({
            type: "RECEIVE_CONTAINER",
            item: {
              name: containerName,
              bytes: metadata["x-container-bytes-used"],
              count: metadata["x-container-object-count"],
              last_modified: metadata["x-last-modified"],
              metadata,
            },
          })
          return metadata
        })
    },
    [containers, dispatch]
  )
  const updateContainerMetadata = React.useCallback(
    (containerName, headers) =>
      apiClient
        .osApi("object-store")
        .post(encodeURIComponent(containerName), {}, { headers: headers }),
    []
  )

  const updateObjectMetadata = React.useCallback(
    (containerName, name, headers) =>
      apiClient
        .osApi("object-store")
        .post(
          encodeURIComponent(containerName + "/" + name),
          {},
          { headers: headers }
        ),
    []
  )

  const copyObject = React.useCallback(
    (containerName, name, target = {}, options = {}) => {
      let copyMetadata = options.withMetadata !== false

      return apiClient
        .osApi("object-store")
        .copy(encodeURIComponent(containerName + "/" + name), {
          headers: {
            destination: encodeURIComponent(
              `/${target.container}/${target.path}`
            ),
            "x-fresh-metadata": copyMetadata ? undefined : true,
          },
        })
    },
    []
  )

  const getAcls = React.useCallback(
    ({ read, write }) =>
      apiClient
        .get("check-acls", { params: { read, write } })
        .then((result) => result.data),
    []
  )
  const endpointURL = React.useCallback(
    (containerName, name) =>
      `${apiClient.osApi("object-store").endpointURL}/${encodeURIComponent(
        containerName + "/" + name
      )}`,
    [apiClient]
  )

  const downloadObject = React.useCallback(
    (containerName, name) => {
      return fetch(endpointURL(containerName, name))
        .then((response) => response.blob())
        .then((blob) => {
          const downloadUrl = URL.createObjectURL(blob)
          const anchor = document.createElement("a")
          anchor.href = downloadUrl
          anchor.download = name

          // Append to the DOM
          document.body.appendChild(anchor)

          // Trigger `click` event
          anchor.click()

          // Remove element from DOM
          document.body.removeChild(anchor)
          URL.revokeObjectURL(downloadUrl)
        })
    },
    [endpointURL, apiClient]
  )

  const uploadObject = React.useCallback(
    (containerName, path, name, file) => {
      if (!path || path === "") path = name
      else {
        if (path[path.length - 1] !== "/") path += "/"
        path += name
      }

      const reader = new FileReader()

      return new Promise((resolve, reject) => {
        reader.onload = (evt) => {
          console.log("::::::::::::::::.", evt.target.result)
          resolve(evt.target.result)
        }
        reader.readAsBinaryString(file)
      }).then((content) =>
        apiClient
          .osApi("object-store")
          .put(encodeURIComponent(containerName + "/" + path), content, {
            headers: {
              "Content-Type": file.type,
            },
          })
      )
    },
    [endpointURL, apiClient]
  )

  const getAuthToken = React.useCallback(() => {
    return apiClient
      .osApi("__auth_token")
      .get("")
      .then((response) => response.data)
  }, [apiClient])

  return {
    endpointURL,
    getAuthToken,
    loadCapabilitiesOnce,
    loadContainersOnce,
    loadAccountMetadataOnce,
    loadObjectMetadata,
    deleteObject,
    deleteObjects,
    copyObject,
    updateObjectMetadata,
    loadContainerMetadata,
    updateContainerMetadata,
    getAcls,
    loadContainerObjects,
    deleteContainer,
    createContainer,
    createFolder,
    downloadObject,
    uploadObject,
  }
}

export default useActions