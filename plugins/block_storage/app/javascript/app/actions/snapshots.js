import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const ajaxHelper = pluginAjaxHelper('block-storage')
const errorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message


//################### SNAPSHOTS #########################
const receiveSnapshot= (snapshot) =>
  ({
    type: constants.RECEIVE_SNAPSHOT,
    snapshot
  })
;

const requestSnapshotDelete= (id) => (
  {
    type: constants.REQUEST_SNAPSHOT_DELETE,
    id
  }
)

const removeSnapshot= (id) => (
  {
    type: constants.REMOVE_SNAPSHOT,
    id
  }
)

const fetchSnapshot= (id) =>
  (dispatch) => {
    return new Promise((handleSuccess,handleError) =>
      ajaxHelper.get(`/snapshots/${id}`).then( (response) => {
        dispatch(receiveSnapshot(response.data.snapshot));
        handleSuccess(response.data.snapshot)
      })
      .catch( (error) => {
        if(error.response.status == 404) {
          dispatch(removeSnapshot(id))
        } else {
          handleError(errorMessage(error))
        }
      })
    )
  }
;

const deleteSnapshot=(id) =>
  (dispatch) =>
    confirm(`Do you really want to delete the snapshot ${id}?`).then(() => {
      return ajaxHelper.delete(`/snapshots/${id}`)
      .then(response => dispatch(requestSnapshotDelete(id)))
      .catch( (error) => {
        addError(React.createElement(ErrorsList, {
          errors: errorMessage(error)
        }))
      });
    }).catch(cancel => true)


//################################

const requestSnapshots= () => (
  {
    type: constants.REQUEST_SNAPSHOTS,
    requestedAt: Date.now()
  }
)

const requestSnapshotsFailure= (error) => (
  {
    type: constants.REQUEST_SNAPSHOTS_FAILURE,
    error
  }
);

const receiveSnapshots= (items,hasNext) =>
  ({
    type: constants.RECEIVE_SNAPSHOTS,
    items,
    hasNext,
    receivedAt: Date.now()
  })
;

const fetchSnapshots= () =>
  function(dispatch,getState) {
    dispatch(requestSnapshots());

    const { marker } = getState().snapshots
    const params = {}
    if(marker) params['marker'] = marker.id

    return ajaxHelper.get('/snapshots', {params: params }).then( (response) => {
      dispatch(receiveSnapshots(response.data.snapshots, response.data.has_next));
    })
    .catch( (error) => {
      dispatch(requestSnapshotsFailure(errorMessage(error)));
    });
  }
;

const loadNext= () =>
  function(dispatch, getState) {
    const {hasNext,isFetching,searchTerm} = getState().snapshots;

    if(!isFetching && hasNext) {
      dispatch(fetchSnapshots()).then(() =>
        // load next if search modus (searchTerm is presented)
        dispatch(loadNextOnSearch(searchTerm))
      )
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
    type: constants.SET_SNAPSHOT_SEARCH_TERM,
    searchTerm
  })

const searchSnapshots= (searchTerm) =>
  function(dispatch) {
    dispatch(setSearchTerm(searchTerm))
    dispatch(loadNextOnSearch(searchTerm))
  }
;

const shouldFetchSnapshots= function(state) {
  if (state.snapshots.isFetching || state.snapshots.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchSnapshotsIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchSnapshots(getState())) { return dispatch(fetchSnapshots()); }
  }
;

//################ SNAPSHOT FORM ###################
const submitNewSnapshotForm= (values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.post('/snapshots/', { snapshot: values }
      ).then((response) => {
        dispatch(receiveSnapshot(response.data))
        handleSuccess()
        addNotice('Snapshot is being created.')
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

const submitEditSnapshotForm= (id,values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.put(`/snapshots/${id}`, { snapshot: values }
      ).then((response) => {
        dispatch(receiveSnapshot(response.data))
        handleSuccess()
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

const submitResetSnapshotStatusForm= (id,values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.put(`/snapshots/${id}/reset-status`, values
      ).then((response) => {
        dispatch(receiveSnapshot(response.data))
        handleSuccess()
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

export {
  fetchSnapshotsIfNeeded,
  fetchSnapshot,
  searchSnapshots,
  deleteSnapshot,
  submitNewSnapshotForm,
  submitEditSnapshotForm,
  submitResetSnapshotStatusForm,
  loadNext
}
