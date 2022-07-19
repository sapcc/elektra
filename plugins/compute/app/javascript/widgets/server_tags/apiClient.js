import { createAjaxHelper } from "lib/ajax_helper"

let apiClient = createAjaxHelper()
apiClient = apiClient.osApi("compute", {
  headers: {
    "X-OpenStack-Nova-API-Version": "2.26",
    "Content-Type": "application/json",
  },
})

export default apiClient
