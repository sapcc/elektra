import * as constants from '../constants';

//########################## SHARES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  hasNext: true,
  currentPage: 0,
  searchTerm: null
};

const requestErrorMessages=(state,{resourceId,requestedAt})=> {
  state[resourceId] = Object.assign(
    {}, initialState, state[resourceId], {isFetching: true, requestedAt}
  )
  return {...state}
};

const requestErrorMessagesFailure=(state,{resourceId}) => {
  state[resourceId] = Object.assign(
    {}, initialState, state[resourceId], {isFetching: false}
  )
  return {...state}
};

const receiveErrorMessages=(state,{resourceId,messages,hasNext,receivedAt}) => {
  let newItems = (state[resourceId].items.slice() || []).concat(messages);
  let items = newItems.filter( (message, pos, arr) => arr.indexOf(message)==pos);
  let currentPage = state[resourceId].currentPage + 1

  state[resourceId] = Object.assign(
    {},
    initialState,
    state[resourceId],
    {
      isFetching: false, receivedAt, items, hasNext, currentPage
    }
  )
  return {...state}
};

const setSearchTerm= (state,{resourceId,searchTerm}) => {
  state[resourceId] = Object.assign(
    {}, initialState, state[resourceId], searchTerm
  )
  return {...state}
}

// shares reducer
export const errorMessages = function(state, action) {
  state = state || {}
  switch (action.type) {
    case constants.RECEIVE_ERROR_MESSAGES: return receiveErrorMessages(state,action);
    case constants.REQUEST_ERROR_MESSAGES: return requestErrorMessages(state,action);
    case constants.REQUEST_ERROR_MESSAGES_FAILURE: return requestErrorMessagesFailure(state,action);
    case constants.SET_ERROR_MESSAGE_SEARCH_TERM: return setSearchTerm(state,action);
    default: return state;
  }
};
