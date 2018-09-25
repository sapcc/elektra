import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  hasNext: true,
  marker: null,
  searchTerm: null,
  error: null
};

const requestSnapshots = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, error: null}
)

const requestSnapshotsFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveSnapshots = (state,{items,receivedAt,hasNext}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
  );

  return {...state,
    receivedAt,
    isFetching: false,
    items: newItems,
    hasNext,
    marker: items[items.length-1]
  }
}

const setSearchTerm= (state,{searchTerm}) => (
  {...state, searchTerm}
);

const receiveSnapshot= function(state,{snapshot}) {
  const index = state.items.findIndex((item) => item.id==snapshot.id);
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=snapshot; } else { items.push(snapshot); }
  return {... state, items: items}
};

const requestSnapshotDelete = (state,{id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].status = constants.SNAPSHOT_STATE_DELETING
  return {...state, items: newItems}
}

const removeSnapshot = (state,{id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

// osImages reducer
export default(state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_SNAPSHOTS: return requestSnapshots(state,action);
    case constants.REQUEST_SNAPSHOTS_FAILURE: return requestSnapshotsFailure(state,action);
    case constants.RECEIVE_SNAPSHOTS: return receiveSnapshots(state,action);
    case constants.RECEIVE_SNAPSHOT: return receiveSnapshot(state,action);
    case constants.SET_SNAPSHOT_SEARCH_TERM: return setSearchTerm(state,action);
    case constants.REQUEST_SNAPSHOT_DELETE: return requestSnapshotDelete(state,action);
    case constants.REMOVE_SNAPSHOT: return removeSnapshot(state,action);
    default: return state;
  }
};
