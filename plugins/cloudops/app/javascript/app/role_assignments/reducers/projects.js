import * as constants from '../constants';

//########################## PROJECTS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  currentPage: 1,
  hasNext: false,
  total: 0
};

const requestProjects=(state,{requestedAt})=> (
  {...state, isFetching: true, requestedAt}
)

const requestProjectsFailure=(state) => (
  {...state, isFetching: false}
)

const receiveProjects=(state,{projects,receivedAt, currentPage, hasNext, total})=> {
  let items = state.items.slice()

  if(currentPage>1) {
    items = items.concat(projects)
  } else {
    items = projects
  }

  return {...state, isFetching: false, items,receivedAt, currentPage, hasNext, total}
}

// entries reducer
export default (state, action) => {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_PROJECTS: return receiveProjects(state,action);
    case constants.REQUEST_PROJECTS: return requestProjects(state,action);
    case constants.REQUEST_PROJECTS_FAILURE: return requestProjectsFailure(state,action);
    default: return state;
  }
};
