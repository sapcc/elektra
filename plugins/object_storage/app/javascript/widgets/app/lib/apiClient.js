let apiClient
let serviceName
let serviceEndpoint

const setApiClient = (client) => {
  apiClient = client
}

const setServiceName = (name) => {
  serviceName = name
}

const setServiceEndpoint = (url) => {
  serviceEndpoint = url
}

export {
  apiClient,
  setApiClient,
  serviceName,
  setServiceName,
  serviceEndpoint,
  setServiceEndpoint,
}
