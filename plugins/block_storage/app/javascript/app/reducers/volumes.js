import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
  hasNext: true,
  searchType: null,
  searchTerm: null,
  limit: 20,
  page: 1,
  sortKey: 'name', 
  sortDir: 'asc',
  error: null
};

const requestVolumes = (state,{searchTerm,searchType})=> (
  {...state, isFetching: true, error: null,searchType,searchTerm}
)

const requestVolumesFailure = (state,{error}) => (
  {...state, isFetching: false, error}
)

const receiveVolumes = (state,{items,receivedAt,hasNext,limit,page,sortKey,sortDir}) => {
  return {...state,
    receivedAt,
    isFetching: false,
    // filter duplicated items
    items: items.filter( (item, pos, arr) => arr.findIndex(i => i.id == item.id)==pos),
    limit,
    page,
    sortDir,
    sortKey,
    hasNext
  }
}

const receiveVolume= function(state,{volume}) {
  const index = state.items.findIndex((item) => item.id==volume.id);
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=volume; } else { items.push(volume); }
  return {... state, items: items}
};

const requestVolumeDelete = (state,{id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].status = 'deleting'
  return {...state, items: newItems}
}

const requestVolumeExtend = (state,{id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].status = constants.VOLUME_STATE_EXTENDING
  return {...state, items: newItems}
}

const removeVolume = (state,{id}) => {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems.splice(index,1)
  return {...state, items: newItems}
}

const requestVolumeAttach = (state,{id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].status = 'attaching'
  return {...state, items: newItems}
}

const requestVolumeDetach = (state,{id})=> {
  const index = state.items.findIndex((item) => item.id==id);
  if (index<0) { return state; }
  let newItems = state.items.slice()
  newItems[index].status = 'detaching'
  return {...state, items: newItems}
}

// osImages reducer
export default(state=initialState, action) => {
  switch (action.type) {
    case constants.REQUEST_VOLUMES: return requestVolumes(state,action);
    case constants.REQUEST_VOLUMES_FAILURE: return requestVolumesFailure(state,action);
    case constants.RECEIVE_VOLUMES: return receiveVolumes(state,action);
    case constants.RECEIVE_VOLUME: return receiveVolume(state,action);
    case constants.REQUEST_VOLUME_DELETE: return requestVolumeDelete(state,action);
    case constants.REQUEST_VOLUME_EXTEND: return requestVolumeExtend(state,action);
    case constants.REQUEST_VOLUME_ATTACH: return requestVolumeAttach(state,action);
    case constants.REQUEST_VOLUME_DETACH: return requestVolumeDetach(state,action);
    case constants.REMOVE_VOLUME: return removeVolume(state,action);
    default: return state;
  }
};
