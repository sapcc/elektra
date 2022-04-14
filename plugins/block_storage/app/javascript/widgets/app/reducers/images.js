import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  error: null
};

const requestImages = (state,{requestedAt})=> (
  {...state, requestedAt, isFetching: true, error: null}
)

const requestImagesFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveImages = (state,{items,receivedAt}) => {
  let newItems = (state.items.slice() || []).concat(items);
  // filter duplicated items
  newItems = newItems.filter( (item, pos, arr) =>
    arr.findIndex(i => i.id == item.id)==pos
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
    case constants.REQUEST_IMAGES: return requestImages(state,action);
    case constants.REQUEST_IMAGES_FAILURE: return requestImagesFailure(state,action);
    case constants.RECEIVE_IMAGES: return receiveImages(state,action);
    default: return state;
  }
};
