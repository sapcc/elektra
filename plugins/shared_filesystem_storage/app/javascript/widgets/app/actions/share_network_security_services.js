import * as constants from "../constants"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"
import { toggleShareNetworkIsNewStatus } from "./share_networks"

//################ SHARE NETWORK SECURITY SERVICES
const receiveShareNetworkSecurityService = (
  shareNetworkId,
  securityService
) => ({
  type: constants.RECEIVE_SHARE_NETWORK_SECURITY_SERVICE,
  shareNetworkId,
  securityService,
  receivedAt: Date.now(),
})
const requestDeleteShareNetworkSecurityService = (
  shareNetworkId,
  securityServiceId
) => ({
  type: constants.REQUEST_DELETE_SHARE_NETWORK_SECURITY_SERVICE,
  shareNetworkId,
  securityServiceId,
})
const deleteShareNetworkSecurityServiceFailure = (
  shareNetworkId,
  securityServiceId
) => ({
  type: constants.DELETE_SHARE_NETWORK_SECURITY_SERVICE_FAILURE,
  shareNetworkId,
  securityServiceId,
})
const removeShareNetworkSecurityService = (
  shareNetworkId,
  securityServiceId
) => ({
  type: constants.DELETE_SHARE_NETWORK_SECURITY_SERVICE_SUCCESS,
  shareNetworkId,
  securityServiceId,
})
const removeShareNetworkSecurityServices = (shareNetworkId) => ({
  type: constants.DELETE_SHARE_NETWORK_SECURITY_SERVICES_SUCCESS,
  shareNetworkId,
})
const requestShareNetworkSecurityServices = (shareNetworkId) => ({
  type: constants.REQUEST_SHARE_NETWORK_SECURITY_SERVICES,
  shareNetworkId,
  requestedAt: Date.now(),
})
const receiveShareNetworkSecurityServices = (shareNetworkId, json) => ({
  type: constants.RECEIVE_SHARE_NETWORK_SECURITY_SERVICES,
  shareNetworkId,
  securityServices: json,
  receivedAt: Date.now(),
})
const fetchShareNetworkSecurityServices = (shareNetworkId) =>
  function (dispatch) {
    dispatch(requestShareNetworkSecurityServices(shareNetworkId))
    ajaxHelper
      .get(`/share-networks/${shareNetworkId}/security-services`)
      .then((response) => {
        dispatch(
          receiveShareNetworkSecurityServices(shareNetworkId, response.data)
        )
      })
      .catch((error) => {
        addError(
          `Could not load share network security services (${error.message})`
        )
      })
  }
const shouldFetchShareNetworkSecurityServices = function (
  state,
  shareNetworkId
) {
  const shareNetworkSecurityServices =
    state.shareNetworkSecurityServices[shareNetworkId]
  if (
    !shareNetworkSecurityServices ||
    (!shareNetworkSecurityServices.isFetching &&
      !shareNetworkSecurityServices.requestedAt)
  ) {
    return true
  }

  return false
}

const fetchShareNetworkSecurityServicesIfNeeded = (shareNetworkId) =>
  function (dispatch, getState) {
    if (shouldFetchShareNetworkSecurityServices(getState(), shareNetworkId)) {
      dispatch(fetchShareNetworkSecurityServices(shareNetworkId))
    }
  }
const deleteShareNetworkSecurityService = (shareNetworkId, securityServiceId) =>
  function (dispatch) {
    dispatch(
      requestDeleteShareNetworkSecurityService(
        shareNetworkId,
        securityServiceId
      )
    )
    ajaxHelper
      .delete(
        `/share-networks/${shareNetworkId}/security-services/${securityServiceId}`
      )
      .then((response) => {
        if (response.data && response.data.errors) {
          dispatch(
            deleteShareNetworkSecurityServiceFailure(
              shareNetworkId,
              securityServiceId
            )
          )
          addError(
            React.createElement(ErrorsList, { errors: response.data.errors })
          )
        } else {
          dispatch(
            removeShareNetworkSecurityService(shareNetworkId, securityServiceId)
          )
        }
      })
      .catch((error) => {
        dispatch(
          deleteShareNetworkSecurityServiceFailure(
            shareNetworkId,
            securityServiceId
          )
        )
        addError(
          `Could not remove security service from share network ${error.message}`
        )
      })
  }
// const submitShareNetworkSecurityServiceForm= (values,{handleSuccess,handleErrors}) =>
//   function(dispatch, getState) {
//
//     let shareNetworkId = values.shareNetworkId
//     delete values['shareNetworkId']
//
//     return ajaxHelper.post(`/share-networks/${shareNetworkId}/security-services`,
//       { security_service: values }
//     ).then(response => {
//       if (response.data.errors) {
//         handleErrors(response.data.errors);
//       } else {
//         dispatch(receiveShareNetworkSecurityService(shareNetworkId, response.data));
//         dispatch(toggleShareNetworkIsNewStatus(shareNetworkId,false));
//         handleSuccess()
//       }
//     }).catch(error => {
//       handleErrors(error.message);
//     })
//   }
// ;

const submitShareNetworkSecurityServiceForm = (values) =>
  function (dispatch) {
    let shareNetworkId = values.shareNetworkId
    delete values["shareNetworkId"]

    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .post(`/share-networks/${shareNetworkId}/security-services`, {
          security_service: values,
        })
        .then((response) => {
          if (response.data.errors) {
            handleErrors({ errors: response.data.errors })
          } else {
            dispatch(
              receiveShareNetworkSecurityService(shareNetworkId, response.data)
            )
            dispatch(toggleShareNetworkIsNewStatus(shareNetworkId, false))
            handleSuccess()
          }
        })
        .catch((error) => handleErrors({ errors: error.message }))
    })
  }
// export
export {
  submitShareNetworkSecurityServiceForm,
  fetchShareNetworkSecurityServicesIfNeeded,
  deleteShareNetworkSecurityService,
}
