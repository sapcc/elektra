import { createAjaxHelper } from "lib/ajax_helper"

let apiClient

// override the baseURL for the apiClient
export function createApiClient(baseURL) {
  apiClient = createAjaxHelper({ baseURL })
  apiClient = apiClient.osApi("identity")
  return apiClient
}

// this is needed because the apiClient is empty when the widget is loaded
// so we need to export the function to get the apiClient
export function getApiClient() {
  return apiClient
}

export default apiClient
