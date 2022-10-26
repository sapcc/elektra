import apiClient from "./apiClient"

export const fetchSecrets = () => {
  return apiClient
    .osApi("key-manager")
    .get("/v1/secrets")
    .then((response) => response.data)
    .catch((error) => console.log(error.message))
}

export const deleteSecret = (id) => {
  return apiClient
    .osApi("key-manager")
    .del(`v1/secrets/${id}`)
    .then((response) => response.data)
    .catch((error) => console.log(error.message))
}

export const createSecret = (formData) => {
  return apiClient
    .osApi("key-manager")
    .post("v1/secrets", formData)
    .then((response) => response.data)
    .catch((error) => console.log(error.message))
}
