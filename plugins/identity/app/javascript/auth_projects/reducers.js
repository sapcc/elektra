import * as constants from './constants';

//########################## ROLES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  showModal: false
};

const toggleModal=(state) => (
  {...state, showModal: !state.showModal}
)

const request=(state,{requestedAt})=> (
  {...state, isFetching: true, requestedAt}
)

const requestFailure=(state) => (
  {...state, isFetching: false}
)

const receive=(state,{items,receivedAt})=> (
  {...state, isFetching: false, items, receivedAt}
)

// entries reducer
export const authProjects = (state, action) => {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.TOGGLE_MODAL: return toggleModal(state,action);
    case constants.RECEIVE_AUTH_PROJECTS: return receive(state,action);
    case constants.REQUEST_AUTH_PROJECTS: return request(state,action);
    case constants.REQUEST_AUTH_PROJECTS_FAILURE: return requestFailure(state,action);
    default: return state;
  }
};
