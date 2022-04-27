import * as constants from '../constants';

//########################## OBJECTS ##############################
const initialState = {
  items: [],
  searchTerm: null,
  searchType: "",
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  currentPage: 1,
  hasNext: false,
  total: 0
};

const requestObjects=(state,{requestedAt})=> (
  {...state, isFetching: true, requestedAt}
)

const requestObjectsFailure=(state) => (
  {...state, isFetching: false}
)

const updateSearchParams=(state, {term,objectType}) => {
  const newState = {...state}
  if(typeof term == 'string') newState.searchTerm = term.trim()
  if(typeof objectType == 'string') newState.searchType = objectType

  return newState
}

const receiveObjects=(state,{objects,receivedAt, currentPage, hasNext, total, replace})=> {
  let items = state.items.slice()

  if(currentPage>1 && !replace) {
    items = items.concat(objects)
  } else {
    items = objects
  }

  return {...state, isFetching: false, items,receivedAt, currentPage, hasNext, total}
}

const receiveObject=(state,{json})=> {
  const index = state.items.findIndex((item) => item.id==json.id);

  let newItems = state.items.slice()
  if (index<0) newItems.push(json)
  else newItems[index] = json
  return {...state, items: newItems}
}

// entries reducer
export default (state, action) => {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_OBJECTS: return receiveObjects(state,action);
    case constants.REQUEST_OBJECTS: return requestObjects(state,action);
    case constants.REQUEST_OBJECTS_FAILURE: return requestObjectsFailure(state,action);

    case constants.RECEIVE_OBJECT: return receiveObject(state,action);
    case constants.UPDATE_SEARCH_PARAMS: return updateSearchParams(state,action)
    default: return state;
  }
};
