import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  requestedAt: null,
  receivedAt: null,
  isFetching: false
};

const requestImageMembers = (state,{imageId,requestedAt})=> {
  state[imageId] = Object.assign(
    {}, initialState, state[imageId], {isFetching: true, requestedAt}
  )

  return {...state}
}

const resetImageMembers = (state,{imageId})=> {
  state[imageId] = Object.assign({}, initialState)
  return {...state}
}

const requestImageMembersFailure = (state) => {
  state[imageId] = Object.assign(
    {}, initialState, state[imageId], {isFetching: false}
  )

  return {...state}
}

const receiveImageMembers = (state,{items,receivedAt,imageId}) => {
  state[imageId] = Object.assign(
    {}, initialState, state[imageId], {isFetching: false, receivedAt, items}
  )
  return {...state}
}

const receiveImageMember = (state,{member,imageId}) => {
  const items = state[imageId].items.slice()
  const index = items.findIndex((item) => item.member_id==member.id);
  // add or replace member
  index<0 ? items.push(member) : items[index] = data
  state[imageId] = {...state[imageId], items}
  return {...state}
}


const requestDeleteImageMember = (state,{memberId,imageId}) => {
  const index = state[imageId].items.findIndex((item) => item.member_id==memberId);
  if (index<0) { return state; }

  const items = state[imageId].items.slice();
  items[index].isDeleting = true;
  state[imageId] = {...state[imageId], items}

  return {...state}
};

const deleteImageMemberFailure= (state,{memberId,imageId}) => {
  const index = state[imageId].items.findIndex((item) => item.member_id==memberId);
  if (index<0) { return state; }

  const items = state[imageId].items.slice();
  items[index].isDeleting = false;
  state[imageId] = {...state[imageId], items}
  return {...state}
};

const deleteImageMember= (state,{memberId,imageId}) => {
  const index = state[imageId].items.findIndex((item) => item.member_id==memberId);
  if (index<0) { return state; }
  const items = state[imageId].items.slice();
  items.splice(index,1);
  state[imageId] = {...state[imageId], items}
  return {...state}
};

// osImages reducer
export const imageMembers = function(state, action) {
  state = state || {}
  switch (action.type) {
    case constants.RECEIVE_IMAGE_MEMBERS: return receiveImageMembers(state,action);
    case constants.RESET_IMAGE_MEMBERS: return resetImageMembers(state,action);
    case constants.RECEIVE_IMAGE_MEMBER: return receiveImageMember(state,action);
    case constants.REQUEST_IMAGE_MEMBERS: return requestImageMembers(state,action);
    case constants.REQUEST_IMAGE_MEMBERS_FAILURE: return requestImageMembersFailure(state,action);
    case constants.REQUEST_DELETE_IMAGE_MEMBER: return requestDeleteImageMember(state,action);
    case constants.DELETE_IMAGE_MEMBER_FAILURE: return deleteImageMemberFailure(state,action);
    case constants.DELETE_IMAGE_MEMBER: return deleteImageMember(state,action);

    default: return state;
  }
};
