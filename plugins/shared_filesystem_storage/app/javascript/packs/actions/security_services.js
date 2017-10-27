import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm, showInfoModal, showErrorModal } from 'dialogs';

//################### SECURITY_SERVICES #########################
const requestSecurityServices= () =>
  ({
    type: constants.REQUEST_SECURITY_SERVICES,
    requestedAt: Date.now()
  })
;

const requestSecurityServicesFailure= () => ({type: constants.REQUEST_SECURITY_SERVICES_FAILURE});

const receiveSecurityServices= json =>
  ({
    type: constants.RECEIVE_SECURITY_SERVICES,
    securityServices: json,
    receivedAt: Date.now()
  })
;

const requestSecurityService= securityServiceId =>
  ({
    type: constants.REQUEST_SECURITY_SERVICE,
    securityServiceId,
    requestedAt: Date.now()
  })
;

const requestSecurityServiceFailure= securityServiceId =>
  ({
    type: constants.REQUEST_SECURITY_SERVICE_FAILURE,
    securityServiceId
  })
;

const receiveSecurityService= json =>
  ({
    type: constants.RECEIVE_SECURITY_SERVICE,
    securityService: json
  })
;

const fetchSecurityServices= () =>
  function(dispatch) {
    dispatch(requestSecurityServices());
    ajaxHelper.get('/security-services').then(response => {
      dispatch(receiveSecurityServices(data));
    }).catch(error => {
      dispatch(requestSecurityServicesFailure());
      showErrorModal(`Could not load security services (%{error.message})`);
    })
  }
;

const shouldFetchSecurityServices= function(state) {
  const { securityServices } = state;
  if (securityServices.isFetching || securityServices.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchSecurityServicesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchSecurityServices(getState())) { return dispatch(fetchSecurityServices()); }
  }
;

const canReloadSecurityService= function(state,securityServiceId) {
  const { items } = state.securityServices;
  let index = -1;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    if (item.id===securityServiceId) {
      index = i;
      break;
    }
  }
  if (index<0) { return true; }
  return !items[index].isFetching;
};

const reloadSecurityService= securityServiceId =>
  function(dispatch,getState) {
    if (!canReloadSecurityService(getState(),securityServiceId)) { return; }

    dispatch(requestSecurityService(securityServiceId));
    ajaxHelper.get(`/security-services/${securityServiceId}`).then(response => {
      dispatch(receiveSecurityService(data));
    }).catch(error => {
      dispatch(requestSecurityServiceFailure());
      showErrorModal(`Could not reload security service (%{error.message})`);
    })
  }
;

const requestDelete=securityServiceId =>
  ({
    type: constants.REQUEST_DELETE_SECURITY_SERVICE,
    securityServiceId
  })
;

const deleteSecurityServiceFailure=securityServiceId =>
  ({
    type: constants.DELETE_SECURITY_SERVICE_FAILURE,
    securityServiceId
  })
;

const removeSecurityService=securityServiceId =>
  ({
    type: constants.DELETE_SECURITY_SERVICE_SUCCESS,
    securityServiceId
  })
;

const deleteSecurityService= securityServiceId =>
  function(dispatch, getState) {
    confirm('Do you really want to delete this security service?').then(() => {
      dispatch(requestDelete(securityServiceId));
      ajaxHelper.delete(`/security-services/${securityServiceId}`).then(response => {
        if (response.data && response.data.errors) {
          showErrorModal(React.createElement(ErrorsList, {errors: response.data.errors}));
        } else {
          dispatch(removeSecurityService(securityServiceId));
        }
      }).catch(error => {
        showErrorModal(React.createElement(ErrorsList, {errors: error.message}));
      })
    }).catch(error => null)
  }
;

// const openDeleteSecurityServiceDialog=function(securityServiceId, options) {
//   if (options == null) { options = {}; }
//   return function(dispatch, getState) {
//     const dependentSecurityServiceNetworks = [];
//     // check if there are dependent securityService networks.
//     // Problem: the securityService networks may not be loaded yet
//     const { securityServiceNetworks } = getState();
//     if (securityServiceNetworks && securityServiceNetworks.items) {
//       for (let securityServiceNetwork of Array.from(securityServiceNetworks.items)) {
//         if (false) { dependentSecurityServiceNetworks.push(securityServiceNetwork); }
//       }
//     }
//
//     if (dependentSecurityServiceNetworks.length===0) {
//       return dispatch(constants.showConfirmDialog({
//         message: options.message || 'Do you really want to delete this security service?' ,
//         confirmCallback() { return dispatch(deleteSecurityService(securityServiceId)); }
//       }));
//     } else {
//       return dispatch(constants.showInfoDialog({title: 'Existing Dependencies', message: `Please remove thi security service from securityService networks (${dependentSecurityServiceNetworks.length}) first!`}));
//     }
//   };
// };


//################ SECURITY_SERVICE FORM ###################

const submitNewSecurityServiceForm= (values, {handleSuccess,handleErrors}) =>
  function(dispatch, getState) {
    const { securityServiceForm } = getState();

    ajaxHelper.post('/security-services', { data: { security_service: values } }).then(response => {
      if (response.data.errors) {
        hanldeErrors(response.data.errors);
      } else {
        dispatch(receiveSecurityService(data));
        handleSuccess()
      }
    }).catch(error => {
      handleErrors(error.message)
    })
  }
;

// export
export {
  fetchSecurityServices,
  fetchSecurityServicesIfNeeded,
  reloadSecurityService,
  deleteSecurityService,
  submitNewSecurityServiceForm
}
