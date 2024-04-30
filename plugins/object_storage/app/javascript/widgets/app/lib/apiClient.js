let apiClient
let serviceName

const setApiClient = (client) => {
  apiClient = client
}

const setServiceName = (name) => {
  serviceName = name
}

export { apiClient, setApiClient, serviceName, setServiceName }
