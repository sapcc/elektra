import "core/components/ajax_helper.coffee"
let ajaxHelper, backendAjaxClient

const setAjaxHelper = (helper) => {
  ajaxHelper = helper
}

const setBackendAjaxClient = (client) => {
  backendAjaxClient = client
}
export { ajaxHelper, backendAjaxClient, setAjaxHelper, setBackendAjaxClient }
