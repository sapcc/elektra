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

const requestVolumes = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, lastError: null}
)

const requestVolumesFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveVolumes = (state,{items,receivedAt,hasNext}) => {
  let newItems = (state.items.slice() || []).concat(items);
  var items = newItems.filter( (item, pos, arr) => arr.indexOf(item)==pos);

  return {...state,
    receivedAt,
    isFetching: false,
    items,
    hasNext,
    marker: items[items.length-1]
  }
}

const setSearchTerm= (state,{searchTerm}) => (
  {...state, searchTerm}
);

// const requestVolume= function(state,{id,requestedAt}) {
//   const index = state.items.findIndex((item) => item.id==id);
//   if (index<0) { return state; }
//
//   const newState = Object.assign(state);
//   newState.items[index].isFetching = true;
//   newState.items[index].requestedAt = requestedAt;
//   return newState;
// };
//
// const requestVolumeFailure=function(state,{id}){
//   const index = state.items.findIndex((item) => item.id==id);
//   if (index<0) { return state; }
//
//   const newState = Object.assign(state);
//   newState.items[index].isFetching = false;
//   return newState;
// };
//
// const receiveVolume= function(state,{port}) {
//   const index = state.items.findIndex((item) => item.id==port.id);
//   const items = state.items.slice();
//   // update or add
//   if (index>=0) { items[index]=port; } else { items.unshift(port); }
//   return {... state, items: items}
// };


// osImages reducer
export default(state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_VOLUMES: return requestVolumes(state,action);
    case constants.REQUEST_VOLUMES_FAILURE: return requestVolumesFailure(state,action);
    case constants.RECEIVE_VOLUMES: return receiveVolumes(state,action);
    case constants.SET_SEARCH_TERM: return setSearchTerm(state,action);
    default: return state;
  }
};
