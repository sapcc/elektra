import "../lib/ajax_helper"
let ajaxHelper, backendAjaxClient

const setAjaxHelper = (helper) => {
  ajaxHelper = helper
}

const setBackendAjaxClient = (client) => {
  backendAjaxClient = client
}
export { ajaxHelper, backendAjaxClient, setAjaxHelper, setBackendAjaxClient }
