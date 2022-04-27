import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  perPage: 100,
  hasNext: true,
  error: null
};

const requestServers = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, error: null}
)

const requestServersFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveServers = (state,{items,receivedAt,hasNext}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
  );

  return {...state,
    receivedAt,
    isFetching: false,
    items: newItems,
    hasNext
  }
}

// osImages reducer
export default(state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_SERVERS: return requestServers(state,action);
    case constants.REQUEST_SERVERS_FAILURE: return requestServersFailure(state,action);
    case constants.RECEIVE_SERVERS: return receiveServers(state,action);
    default: return state;
  }
};
