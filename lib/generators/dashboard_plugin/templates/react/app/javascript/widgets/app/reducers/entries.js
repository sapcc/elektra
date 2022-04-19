import * as constants from '../constants';

//########################## ENTRIES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestEntries=(state,{requestedAt})=>
  Object.assign({}, state, {
    isFetching: true,
    requestedAt
  });

const requestEntriesFailure=function(state){
  return Object.assign({}, state, {
    isFetching: false
  });
};

const receiveEntries=(state,{entries,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    items: entries,
    receivedAt
  })
;

const requestEntry= function(state,{entryId,requestedAt}) {
  const index = state.items.findIndex((item) => item.id==entryId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isFetching = true;
  return Object.assign({},state,{items});
};

const requestEntryFailure=function(state,{entryId}){
  const index = state.items.findIndex((item) => item.id==entryId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isFetching = false;
  return Object.assign({},state,{items});
};

const receiveEntry= function(state,{entry}) {
  const index = state.items.findIndex((item) => item.id==entry.id);
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=entry; } else { items.push(entry); }
  return Object.assign({},state,{items});
};

const requestDeleteEntry= function(state,{entryId}) {
  const index = state.items.findIndex((item) => item.id==entryId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = true;
  return Object.assign({},state,{items});
};

const deleteEntryFailure= function(state,{entryId}) {
  const index = state.items.findIndex((item) => item.id==entryId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = false;
  return Object.assign({},state,{items});
};

const deleteEntrySuccess= function(state,{entryId}) {
  const index = state.items.findIndex((item) => item.id==entryId);
  if (index<0) { return state; }
  const items = state.items.slice();
  items.splice(index,1);
  return Object.assign({},state,{items});
};

const filterEntries= (state,{term}) => {
  const items = state.items.slice();
  const regex = new RegExp(term.trim(), "i")

  for(let i of items) {
    if (`${i.name} ${i.id} ${i.description}`.search(regex)>=0)
      i.isHidden=false
    else i.isHidden=true
  }
  return Object.assign({},state,{items});
}

// entries reducer
export const entries = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.FILTER_ENTRIES: return filterEntries(state,action);
    case constants.RECEIVE_ENTRIES: return receiveEntries(state,action);
    case constants.REQUEST_ENTRIES: return requestEntries(state,action);
    case constants.REQUEST_ENTRIES_FAILURE: return requestEntriesFailure(state,action);
    case constants.REQUEST_ENTRY: return requestEntry(state,action);
    case constants.REQUEST_ENTRY_FAILURE: return requestEntryFailure(state,action);
    case constants.RECEIVE_ENTRY: return receiveEntry(state,action);
    case constants.REQUEST_DELETE_ENTRY: return requestDeleteEntry(state,action);
    case constants.DELETE_ENTRY_FAILURE: return deleteEntryFailure(state,action);
    case constants.DELETE_ENTRY_SUCCESS: return deleteEntrySuccess(state,action);

    default: return state;
  }
};
