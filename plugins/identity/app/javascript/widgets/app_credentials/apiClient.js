import { createAjaxHelper } from "lib/ajax_helper"

let apiClient = createAjaxHelper()
apiClient = apiClient.osApi("identity")

export default apiClient
