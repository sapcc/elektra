import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';
import { removeShareRules } from './share_rules';

//################### SHARES #########################
const requestShares= () =>
  ({
    type: constants.REQUEST_SHARES,
    requestedAt: Date.now()
  })
;

const requestSharesFailure= () => ({type: constants.REQUEST_SHARES_FAILURE});

const receiveShares= (json, hasNext) =>
  ({
    type: constants.RECEIVE_SHARES,
    shares: json,
    hasNext,
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

const fetchShares= (page=null) =>
  function(dispatch,getState) {
    dispatch(requestShares());

    return ajaxHelper.get('/shares', {params: { page } }).then( (response) => {
      if (response.data.errors) {
        addError(React.createElement(ErrorsList, {errors: response.data.errors}))
      } else {
        dispatch(receiveShares(response.data.shares, response.data.has_next));
      }
    })
    .catch( (error) => {
      dispatch(requestSharesFailure());
      addError(`Could not load shares (${error.message})`)
    });
  }
;

const loadNext= () =>
  function(dispatch, getState) {
    let state = getState();

    if(!state.shares.isFetching && state.shares.hasNext) {
      dispatch(fetchShares(state.shares.currentPage+1)).then(() => {
        // load next if search modus (searchTerm is presented)
        dispatch(loadNextOnSearch(state.shares.searchTerm))
      })
    }
  }
;

const loadNextOnSearch=(searchTerm) =>
  function(dispatch) {
    if(searchTerm && searchTerm.trim().length>0) {
      dispatch(loadNext());
    }
  }
;

const setSearchTerm= (searchTerm) =>
  ({
    type: constants.SET_SEARCH_TERM,
    searchTerm
  })

const searchShares= (searchTerm) =>
  function(dispatch) {
    dispatch(setSearchTerm(searchTerm))
    dispatch(loadNextOnSearch(searchTerm))
  }
;

const shouldFetchShares= function(state) {
  const { shares } = state;
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
  let index = items.findIndex(i=>i.id==shareId)
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
    const shareSnapshots = [];
    // check if there are dependent snapshots.
    // Problem: the snapshots may not be loaded yet
    const { snapshots } = getState();
    if (snapshots && snapshots.items) {
      for (let snapshot of snapshots.items) {
        if (snapshot.share_id===shareId) { shareSnapshots.push(snapshot); }
      }
    }

    if (shareSnapshots.length > 0) {
      return addNotice(`Share still has ${shareSnapshots.length} dependent snapshots. Please remove dependent snapshots first.`)
    }

    confirm(`Do you really want to delete the share ${shareId}?`).then(() => {
      dispatch(requestDelete(shareId));
      ajaxHelper.delete(`/shares/${shareId}`).then((response) => {
        if (response.data && response.data.errors) {
          addError(React.createElement(ErrorsList, {errors: response.data.errors}));
          dispatch(deleteShareFailure(shareId))
        } else {
          dispatch(removeShare(shareId));
          dispatch(removeShareRules(shareId));
        }
      }).catch((error) => {
        dispatch(deleteShareFailure(shareId))
        addError(React.createElement(ErrorsList, {errors: error.message}));
      })
    }).catch((aborted) => null)
  }
;

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
  const { shares } = state;
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
const submitEditShareForm= (values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.put(
        `/shares/${values.id}`,
        { share: values }
      ).then((response) => {
        if (response.data.errors) handleErrors({errors: response.data.errors});
        else {
          dispatch(receiveShare(response.data))
          handleSuccess()
        }
      }).catch(error => handleErrors({errors:error.message}))
    )
);

const submitNewShareForm= (values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.post(
        `/shares`,
        { share: values }
      ).then((response) => {
        if (response.data.errors) handleErrors({errors: response.data.errors});
        else {
          dispatch(receiveShare(response.data))
          handleSuccess()
        }
      }).catch(error => handleErrors({errors: error.message}))
    )
);

//####################### AVAILABILITY ZONES ###########################
// Manila availability zones, not nova!!!
const shouldFetchAvailabilityZones= function(state) {
  const azs = state.availabilityZones;

  if (!azs.isFetching && !azs.requestedAt) {
    return true;
  } else {
    return false;
  }

};
const requestAvailableZones= () => ({
  type: constants.REQUEST_AVAILABLE_ZONES,
  requestedAt: Date.now()
});

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
  submitEditShareForm,
  searchShares,
  loadNext
}
