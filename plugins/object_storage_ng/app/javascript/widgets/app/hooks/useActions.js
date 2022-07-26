import React from "react"
import apiClient from "../lib/apiClient"
import { useDispatch, useGlobalState } from "../stateProvider"

const useActions = () => {
  const { containers, objects } = useGlobalState()
  const dispatch = useDispatch()

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

  return {
    loadContainersOnce,
    loadContainerObjectsOnce,
    loadObjectMetadata,
    deleteObject,
  }
}

export default useActions
