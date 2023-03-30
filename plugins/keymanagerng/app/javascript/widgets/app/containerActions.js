import apiClient from "./apiClient"

export const getContainers = ({ queryKey }) => {
  const [_key, paginationOptions] = queryKey
  return fetchContainers(paginationOptions)
}

export const fetchContainers = (options) => {
  return apiClient
    .osApi("key-manager")
    .get("/v1/containers", {
      params: {
        ...options,
        sort: "created:desc",
      },
    })
    .then((response) => {
      return response?.data
    })
}

export const getContainer = ({ queryKey }) => {
  const [_key, uuid] = queryKey
  return fetchContainer(uuid)
}

export const fetchContainer = (uuid) => {
  return apiClient
    .osApi("key-manager")
    .get("/v1/containers/" + uuid)
    .then((response) => {
      return response?.data
    })
    .catch((error) => {
      return error
    })
}

export const delContainer = ({ queryKey }) => {
  const [_key, uuid] = queryKey
  return deleteContainer(uuid)
}

export const deleteContainer = (delObj) => {
  console.log("deleteContainers id:", delObj.id)
  return apiClient
    .osApi("key-manager")
    .delete(`v1/containers/${delObj.id}`)
    .then((response) => {
      return response?.data
    })
}

export const addContainer = ({ queryKey }) => {
  const [_key, formData] = queryKey
  return createContainer(formData)
}

export const createContainer = (formData) => {
  return apiClient
    .osApi("key-manager")
    .post("v1/containers", formData)
    .then((response) => {
      return response?.data
    })
}
