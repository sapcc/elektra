import { imageConstants } from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  hasNext: true,
  currentPage: 0,
  searchTerm: null
};

const requestOsImages=(state,{requestedAt})=>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestOsImagesFailure=function(state,...rest){
  const obj = rest[0];
  return Object.assign({},state,{isFetching: false});
};

const receiveOsImages=(state,{osImages,hasNext,receivedAt}) => {
  let newItems = (state.items.slice() || []).concat(osImages);
  var items = newItems.filter( (osImage, pos, arr) => arr.indexOf(osImage)==pos);

  return Object.assign({},state,{
    isFetching: false,
    items: items,
    hasNext: hasNext,
    currentPage: (state.currentPage + 1),
    receivedAt
  })
};

const requestOsImage= function(state,{osImageId,requestedAt}) {
  const index = state.items.findIndex((item) => item.id==osImageId);
  if (index<0) { return state; }

  const newState = Object.assign(state);
  newState.items[index].isFetching = true;
  newState.items[index].requestedAt = requestedAt;
  return newState;
};

const requestOsImageFailure=function(state,{osImageId}){
  const index = state.items.findIndex((item) => item.id==osImageId);
  if (index<0) { return state; }

  const newState = Object.assign(state);
  newState.items[index].isFetching = false;
  return newState;
};

const receiveOsImage= function(state,{osImage}) {
  const index = state.items.findIndex((item) => item.id==osImage.id);
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=osImage; } else { items.unshift(osImage); }
  return Object.assign({},state,{items});
};

const requestDeleteOsImage= function(state,{osImageId}) {
  const index = state.items.findIndex((item) => item.id==osImageId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = true;
  return Object.assign({},state,{items});
};

const deleteOsImageFailure= function(state,{osImageId}) {
  const index = state.items.findIndex((item) => item.id==osImageId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = false;
  return Object.assign({},state,{items});
};

const deleteOsImageSuccess= function(state,{osImageId}) {
  const index = state.items.findIndex((item) => item.id==osImageId);
  if (index<0) { return state; }
  const items = state.items.slice();
  items.splice(index,1);
  let currentPage = items.length==0 ? 0 : state.currentPage;
  return Object.assign({},state,{items, currentPage});
};

const setSearchTerm= (state,{searchTerm}) => {
  return Object.assign({},state,{searchTerm});
}

// osImages reducer
export const osImages = (type) => function(state, action) {
  const constants = imageConstants(type)
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.SET_SEARCH_TERM: return setSearchTerm(state,action);
    case constants.RECEIVE_IMAGES: return receiveOsImages(state,action);
    case constants.REQUEST_IMAGES: return requestOsImages(state,action);
    case constants.REQUEST_IMAGES_FAILURE: return requestOsImagesFailure(state,action);
    case constants.REQUEST_IMAGE: return requestOsImage(state,action);
    case constants.REQUEST_IMAGE_FAILURE: return requestOsImageFailure(state,action);
    case constants.RECEIVE_IMAGE: return receiveOsImage(state,action);
    case constants.REQUEST_DELETE_IMAGE: return requestDeleteOsImage(state,action);
    case constants.DELETE_IMAGE_FAILURE: return deleteOsImageFailure(state,action);
    case constants.DELETE_IMAGE_SUCCESS: return deleteOsImageSuccess(state,action);

    default: return state;
  }
};
