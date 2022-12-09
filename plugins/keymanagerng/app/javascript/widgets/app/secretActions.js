import apiClient from "./apiClient"

export const fetchSecrets = (options) => {
  console.log("fetchSecrets options: ", options)
  return apiClient
    .osApi("key-manager")
    .get("/v1/secrets", { params: { ...options, limit: 10 } })
    .then((response) => response.data)
    .catch((error) => console.log(error.data))
}

export const fetchSecret = (uuid) => {
  console.log("fetchSecret uuid: ", uuid)
  return apiClient
    .osApi("key-manager")
    .get("/v1/secrets/" + uuid)
    .then((response) => response.data)
    .catch((error) => console.log(error.data))
}

export const deleteSecret = (id) => {
  return apiClient
    .osApi("key-manager")
    .delete(`v1/secrets/${id}`)
    .then((response) => response.data)
    .catch((error) => console.log(error.data))
}

export const createSecret = (formData) => {
  return apiClient
    .osApi("key-manager")
    .post("v1/secrets", formData)
    .then((response) => response.data)
}
