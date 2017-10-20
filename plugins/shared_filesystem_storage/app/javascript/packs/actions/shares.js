import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm, showInfoModal, showErrorModal } from 'dialogs';
import { ErrorsList } from 'elektra-form/components/errors_list';
import { removeShareRules } from './share_rules';

//################### SHARES #########################
const requestShares= () =>
  ({
    type: constants.REQUEST_SHARES,
    requestedAt: Date.now()
  })
;

const requestSharesFailure= () => ({type: constants.REQUEST_SHARES_FAILURE});

const receiveShares= json =>
  ({
    type: constants.RECEIVE_SHARES,
    shares: json,
    receivedAt: Date.now()
  })
;

const requestShare= shareId =>
  ({
    type: constants.REQUEST_SHARE,
    shareId,
    requestedAt: Date.now()
  })
;

const requestShareFailure= shareId =>
  ({
    type: constants.REQUEST_SHARE_FAILURE,
    shareId
  })
;

const receiveShare= json =>
  ({
    type: constants.RECEIVE_SHARE,
    share: json
  })
;

const fetchShares= () =>
  function(dispatch) {
    dispatch(requestShares());
    ajaxHelper.get('/shares')
      .then( (response) => {
        return dispatch(receiveShares(response.data));
      })
      .catch( (error) => {
        console.log('fetchShares', error)
        dispatch(requestSharesFailure());
        //return dispatch(app.showErrorDialog({title: 'Could not load shares', message:jqXHR.responseText}));
      });
  }

const shouldFetchShares= function(state) {
  const { shares } = state.shared_filesystem_storage;
  if (shares.isFetching || shares.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchSharesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchShares(getState())) { return dispatch(fetchShares()); }
  }
;

const canReloadShare= function(state,shareId) {
  const { items } = state.shares;
  let index = -1;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    if (item.id===shareId) {
      index = i;
      break;
    }
  }
  if (index<0) { return true; }
  return !items[index].isFetching;
};

const reloadShare= shareId =>
  function(dispatch,getState) {
    if (!canReloadShare(getState(),shareId)) { return; }

    dispatch(requestShare(shareId));
    ajaxHelper.get(`/shares/${shareId}`)
      .then((response) => dispatch(receiveShare(response.data)))
      .catch((error) => {
        dispatch(requestShareFailure());
        // return dispatch(app.showErrorDialog({title: 'Could not reload share', message:jqXHR.responseText}));
      }
    )
  }
;

const requestDelete=shareId =>
  ({
    type: constants.REQUEST_DELETE_SHARE,
    shareId
  })
;

const deleteShareFailure=shareId =>
  ({
    type: constants.DELETE_SHARE_FAILURE,
    shareId
  })
;

const removeShare=shareId =>
  ({
    type: constants.DELETE_SHARE_SUCCESS,
    shareId
  })
;

const deleteShare= shareId =>
  function(dispatch, getState) {

    confirm(`Do you really want to delete the share ${shareId}?`).then(() => {
      dispatch(requestDelete(shareId));
      ajaxHelper.delete(`/shares/${shareId}`).then((response) => {
        if (response.data && response.data.errors) {
          showErrorModal(React.createElement(ErrorsList, {errors: response.data.errors}));
        } else {
          dispatch(removeShare(shareId));
          dispatch(removeShareRules(shareId));
        }
      }).catch((error) => {
        showErrorModal(React.createElement(ErrorsList, {errors: error.message}));
      })
    }).catch((aborted) => null)
  }
;

// const openDeleteShareDialog=function(shareId, options) {
//   if (options == null) { options = {}; }
//   return function(dispatch, getState) {
//     const shareSnapshots = [];
//     // check if there are dependent snapshots.
//     // Problem: the snapshots may not be loaded yet
//     const { snapshots } = getState();
//     if (snapshots && snapshots.items) {
//       for (let snapshot of Array.from(snapshots.items)) {
//         if (snapshot.share_id===shareId) { shareSnapshots.push(snapshot); }
//       }
//     }
//
//     if (shareSnapshots.length===0) {
//       return dispatch(app.showConfirmDialog({
//         message: options.message || 'Do you really want to delete this share?' ,
//         confirmCallback() { return dispatch(deleteShare(shareId)); }
//       }));
//     } else {
//       return dispatch(app.showInfoDialog({title: 'Existing Dependencies', message: `Please delete dependent snapshots(${shareSnapshots.length}) first!`}));
//     }
//   };
// };

//############### SHARE EXPORT LOCATIONS ################
const requestShareExportLocations= shareId =>
  ({
    type: constants.REQUEST_SHARE_EXPORT_LOCATIONS,
    shareId
  })
;

const receiveShareExportLocations= (shareId, json) =>
  ({
    type: constants.RECEIVE_SHARE_EXPORT_LOCATIONS,
    shareId,
    export_locations: json,
    receivedAt: Date.now()
  })
;

const fetchShareExportLocations= shareId =>
  function(dispatch) {
    dispatch(requestShareExportLocations(shareId));
    ajaxHelper.get(`/shares/${shareId}/export_locations`).then(response => {
      dispatch(receiveShareExportLocations(shareId,response.data))
    }).catch((error) => {
      // dispatch(app.showErrorDialog({title: 'Could not load share export locations', message:jqXHR.responseText}));
    });
  }
;

const shouldFetchShareExportLocations= function(state, shareId) {
  const { shares } = state.shared_filesystem_storage;
  if(!(shares && shares.items && shareId)) return false

  let share = shares.items.find(share => share.id==shareId)
  if(share && share.export_locations) return false
  return true
};

const fetchShareExportLocationsIfNeeded = shareId =>
  function(dispatch, getState) {
    if (shouldFetchShareExportLocations(getState(), shareId)) {
      return dispatch(fetchShareExportLocations(shareId));
    }
  }
;

//################ SHARE FORM ###################
const submitShareForm = (method, path, values) => (
  function(dispatch) {
    ajaxHelper.method(path, { share: values }).then((response) => {
      if (response.data.errors) {
        handleErrors(response.data.errors);
      } else {
        dispatch(receiveShare(response.data))
        handleSuccess()
      }
    })
    .catch(error => {
      handleErrors(error.message)
    })
  }
);

const submitEditShareForm= (values,{handleSuccess,handleErrors}) => (
  function(dispatch) {
    ajaxHelper.put(`/shares/${values.id}`, { share: values }).then((response) => {
      if (response.data.errors) {
        handleErrors(response.data.errors);
      } else {
        dispatch(receiveShare(response.data))
        handleSuccess()
      }
    })
    .catch(error => {
      handleErrors(error.message)
    })
  }
);

const submitNewShareForm= (values,{handleSuccess,handleErrors}) => (
  function(dispatch) {
    ajaxHelper.post(`/shares`, { share: values }).then((response) => {
      if (response.data.errors) {
        handleErrors(response.data.errors);
      } else {
        dispatch(receiveShare(response.data))
        handleSuccess()
      }
    })
    .catch(error => {
      handleErrors(error.message)
    })
  }
);

//####################### AVAILABILITY ZONES ###########################
// Manila availability zones, not nova!!!
const shouldFetchAvailabilityZones= function(state) {
  const azs = state.shared_filesystem_storage.availabilityZones;
  if (azs.isFetching) {
    return false;
  } else if (azs.receivedAt) {
    return false;
  } else {
    return true;
  }
};
const requestAvailableZones= () => ({type: constants.REQUEST_AVAILABLE_ZONES});

const requestAvailableZonesFailure= () => ({type: constants.REQUEST_AVAILABLE_ZONES_FAILURE});

const receiveAvailableZones= json =>
  ({
    type: constants.RECEIVE_AVAILABLE_ZONES,
    availabilityZones: json,
    receivedAt: Date.now()
  })
;

const fetchAvailabilityZones=() =>
  function(dispatch) {
    dispatch(requestAvailableZones());
    ajaxHelper.get('/shares/availability_zones')
      .then((response) => dispatch(receiveAvailableZones(response.data)))
      .catch((error) => {
        console.log(error)
        dispatch(requestAvailableZonesFailure());
      })
  }
;

const fetchAvailabilityZonesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchAvailabilityZones(getState())) { return dispatch(fetchAvailabilityZones()); }
  }
;

export {
  fetchShares,
  fetchSharesIfNeeded,
  reloadShare,
  deleteShare,
  fetchShareExportLocationsIfNeeded,
  fetchAvailabilityZonesIfNeeded,
  submitNewShareForm,
  submitEditShareForm
}
