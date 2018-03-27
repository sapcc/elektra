import * as constants from '../constants';

//########################## IMAGES ##############################
const initialState = {
  items: [],
  requestedAt: null,
  receivedAt: null,
  isFetching: false
};

const requestImageMembers = (state,{requestedAt})=>(
  {...state, isFetching: true, requestedAt}
)

const requestImageMembersFailure = (state) =>(
  {...state, isFetching: false }
)

const receiveImageMembers = (state,{items,receivedAt}) =>(
  {...state, isFetching: false, items, receivedAt}
)

const receiveImageMember = (state,{member}) => {
  const items = state.items.slice()
  const index = items.findIndex((item) => item.id==member.id);
  // add or replace member
  index<0 ? items.push(member) : items[index] = data

  return {...state, items}
}


const requestDeleteImageMember = (state,{memberId}) => {
  const index = state.items.findIndex((item) => item.id==memberId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = true;
  return {...state, items}
};

const deleteImageMemberFailure= (state,{memberId}) => {
  const index = state.items.findIndex((item) => item.id==memberId);
  if (index<0) { return state; }

  const items = state.items.slice();
  items[index].isDeleting = false;
  return {...state, items}
};

const deleteImageMember= (state,{memberId}) => {
  const index = state.items.findIndex((item) => item.id==memberId);
  if (index<0) { return state; }
  const items = state.items.slice();
  items.splice(index,1);
  return {...state, items}
};

// osImages reducer
export const imageMembers = (type) => function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_IMAGE_MEMBERS: return receiveImageMembers(state,action);
    case constants.RECEIVE_IMAGE_MEMBER: return receiveImageMember(state,action);
    case constants.REQUEST_IMAGE_MEMBERS: return requestImageMembers(state,action);
    case constants.REQUEST_IMAGE_MEMBERS_FAILURE: return requestImageMembersFailure(state,action);
    case constants.REQUEST_DELETE_IMAGE_MEMBER: return requestDeleteImageMember(state,action);
    case constants.DELETE_IMAGE_MEMBER_FAILURE: return deleteImageMemberFailure(state,action);
    case constants.DELETE_IMAGE_MEMBER: return deleteImageMember(state,action);

    default: return state;
  }
};
