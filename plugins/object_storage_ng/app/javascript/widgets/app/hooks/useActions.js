import React from "react"
import { useLocation } from "react-router-dom"
import { useDispatch, useGlobalState } from "../stateProvider"

import { createAjaxHelper } from "lib/ajax_helper"

const useActions = () => {
  const location = useLocation()
  const apiClient = React.useMemo(
    () =>
      createAjaxHelper({
        baseURL: window.location.pathname.replace(location.pathname, ""),
      }),
    [location.pathname]
  )

  const { capabilities, containers, objects } = useGlobalState()
  const dispatch = useDispatch()

  const loadCapabilitiesOnce = React.useCallback(
    (options = {}) => {
      if (capabilities.updatedAt && !options.reload) return

      dispatch({ type: "REQUEST_CAPABILITIES" })
      apiClient
        .osApi("object-store")
        .get("info", { params: { path_prefix: "/" } })
        .then((response) =>
          dispatch({ type: "RECEIVE_CAPABILITIES", data: response.data })
        )
        .catch((error) =>
          dispatch({ type: "RECEIVE_CAPABILITIES_ERROR", error: error.message })
        )
    },
    [dispatch, capabilities.updatedAt]
  )

  const loadContainersOnce = React.useCallback(
    (options = {}) => {
      if (containers.updatedAt && !options.reload) return

      dispatch({ type: "REQUEST_CONTAINERS" })
      apiClient
        .osApi("object-store")
        .get("")
        .then((response) => {
          dispatch({ type: "RECEIVE_CONTAINERS", items: response.data })
        })
        .catch((error) =>
          dispatch({ type: "RECEIVE_CONTAINERS_ERROR", error: error.message })
        )
    },
    [dispatch, containers.updatedAt]
  )

  const loadContainerObjectsOnce = React.useCallback(
    (containerName, options = {}) => {
      if (objects[containerName]?.updatedAt && !options.reload) return

      dispatch({ type: "REQUEST_CONTAINER_OBJECTS", containerName })
      apiClient
        .osApi("object-store")
        .get(containerName)
        .then((response) => {
          dispatch({
            type: "RECEIVE_CONTAINER_OBJECTS",
            containerName,
            items: response.data,
          })
        })
        .catch((error) => {
          dispatch({
            type: "RECEIVE_CONTAINER_OBJECTS_ERROR",
            containerName,
            error: error.message,
          })
        })
    },
    [dispatch, objects]
  )

  const loadSubObjects = React.useCallback(
    (containerName, options = {}) =>
      apiClient
        .osApi("object-store")
        .get(containerName, { params: options })
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
        .head(containerName + "/" + name)
        .then((response) => response.headers),
    []
  )

  const deleteObject = React.useCallback(
    (containerName, name) =>
      apiClient
        .osApi("object-store")
        .delete(containerName + "/" + name)
        .then((response) => response.data),
    []
  )

  const loadContainerMetadata = React.useCallback(
    (containerName) =>
      apiClient
        .osApi("object-store")
        .head(containerName)
        .then((response) => response.headers),
    []
  )
  const updateContainerMetadata = React.useCallback(
    (containerName, headers) =>
      apiClient
        .osApi("object-store")
        .post(containerName, {}, { headers: headers }),
    []
  )

  const getAcls = React.useCallback(
    ({ read, write }) =>
      apiClient
        .get("check-acls", { params: { read, write } })
        .then((result) => result.data),
    []
  )

  return {
    loadCapabilitiesOnce,
    loadContainersOnce,
    loadContainerObjectsOnce,
    loadObjectMetadata,
    deleteObject,
    loadContainerMetadata,
    updateContainerMetadata,
    getAcls,
    loadSubObjects,
  }
}

export default useActions
