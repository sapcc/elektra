import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';

const ajaxHelper = pluginAjaxHelper('block-storage')

//################### IMAGES #########################
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

const receiveSnapshots= (items) =>
  ({
    type: constants.RECEIVE_SNAPSHOTS,
    items,
    receivedAt: Date.now()
  })
;

const fetchSnapshots= () =>
  function(dispatch) {
    dispatch(requestSnapshots());

    return ajaxHelper.get('snapshots').then( (response) => {
      if (response.data.errors) {
        throws(response.data.errors)
      } else {
        dispatch(receiveSnapshots(response.data.snapshots));
      }
    })
    .catch( (error) => {
      dispatch(requestSnapshotsFailure(error.message));
    });
  }
;

const shouldFetchSnapshots= function(state) {
  const { snapshots } = state;
  if (snapshots.isFetching || snapshots.requestedAt) {
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
  fetchSnapshotsIfNeeded
}
