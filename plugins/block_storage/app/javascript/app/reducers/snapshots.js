import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  lastError: null
};

const requestSnapshots = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, lastError: null}
)

const requestSnapshotsFailure = (state,{error}) => (
  {...state, isFetching: false, lastError: error}
)

const receiveSnapshots = (state,{items,receivedAt}) => (
  {...state, receivedAt, isFetching: false, items}
)

// osImages reducer
export default(state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_SNAPSHOTS: return requestSnapshots(state,action);
    case constants.REQUEST_SNAPSHOTS_FAILURE: return requestSnapshotsFailure(state,action);
    case constants.RECEIVE_SNAPSHOTS: return receiveSnapshots(state,action);
    default: return state;
  }
};
