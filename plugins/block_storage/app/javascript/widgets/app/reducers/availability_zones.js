import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  error: null
};

const requestAvailabilityZones = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, error: null}
)

const requestAvailabilityZonesFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveAvailabilityZones = (state,{items,receivedAt}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.zoneName == item.zoneName)==pos
  );

  return {...state,
    receivedAt,
    isFetching: false,
    items: newItems
  }
}

// osImages reducer
export default(state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_AVAILABILITY_ZONES: return requestAvailabilityZones(state,action);
    case constants.REQUEST_AVAILABILITY_ZONES_FAILURE: return requestAvailabilityZonesFailure(state,action);
    case constants.RECEIVE_AVAILABILITY_ZONES: return receiveAvailabilityZones(state,action);
    default: return state;
  }
};
