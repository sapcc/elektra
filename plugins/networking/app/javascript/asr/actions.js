import { pluginAjaxHelper } from 'ajax_helper';

const ajaxHelper = pluginAjaxHelper('networking')

const fetchRouter = (routerId) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper.get(`/asr/routers/${routerId}`).then((response) => {
      if (response.data.error) return handleErrors(response.data.error)
      else return handleSuccess(response.data.router)
    }).catch((error) => handleErrors(error.message))
  })
;

const syncRouter = (routerId) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper.put(`/asr/routers/${routerId}`).then((response) => {
      if (response.data.error) return handleErrors(response.data.error)
      else return handleSuccess(response.data.router)
    }).catch((error) => handleErrors(error.message))
  })
;

const fetchConfig = (routerId) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper.get(`/asr/configs/${routerId}`).then((response) => {
      if (response.data.error) return handleErrors(response.data.error)
      else return handleSuccess(response.data.config)
    }).catch((error) => handleErrors(error.message))
  })
;

const fetchStatistics = (routerId) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper.get(`/asr/statistics/${routerId}`).then((response) => {
      if (response.data.error) return handleErrors(response.data.error)
      else return handleSuccess(response.data.statistics)
    }).catch((error) => handleErrors(error.message))
  })
;

export {
  fetchRouter,
  fetchConfig,
  fetchStatistics,
  syncRouter
}
