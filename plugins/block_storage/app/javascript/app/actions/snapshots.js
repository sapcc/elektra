import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';

const ajaxHelper = pluginAjaxHelper('block-storage')

//################### SNAPSHOTS #########################
const requestSnapshot= (id) => (
  {
    type: constants.REQUEST_SNAPSHOT,
    id
  }
)

const requestSnapshotFailure= (id) => (
  {
    type: constants.REQUEST_SNAPSHOT_FAILURE
  }
);

const receiveSnapshot= (snapshot) =>
  ({
    type: constants.RECEIVE_SNAPSHOT,
    snapshot
  })
;

const fetchSnapshot= (id) =>
  (dispatch) => {
    dispatch(requestSnapshot(id));

    return new Promise((handleSuccess,handleError) =>
      ajaxHelper.get(`/snapshots/${id}`).then( (response) => {
        if (response.data.errors) {
          throw(response.data.errors)
        } else {
          dispatch(receiveSnapshot(response.data.snapshot));
          handleSuccess(response.data.snapshot)
        }
      })
      .catch( (error) => {
        dispatch(requestSnapshotFailure(id));
        handleError(error.message || error)
      })
    )
  }
;

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
      if (response.data.errors) {
        throw(response.data.errors)
      } else {
        dispatch(receiveSnapshots(response.data.snapshots, response.data.has_next));
      }
    })
    .catch( (error) => {
      dispatch(requestSnapshotsFailure(error.message || error));
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

export {
  fetchSnapshotsIfNeeded,
  fetchSnapshot,
  searchSnapshots,
  loadNext
}
