import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  updatedAt: null,
  isFetching: false,
  error: null
};

const requestShareServers = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, error: null}
)

const requestShareServersFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveShareServers = (state,{items,updatedAt}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
  );

  return {...state,
    updatedAt,
    isFetching: false,
    items: newItems
  }
}

// osImages reducer
export const shareServers = (state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_SHARE_SERVERS: return requestShareServers(state,action);
    case constants.REQUEST_SHARE_SERVERS_FAILURE: return requestShareServersFailure(state,action);
    case constants.RECEIVE_SHARE_SERVERS: return receiveShareServers(state,action);
    default: return state;
  }
};
