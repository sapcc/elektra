import * as constants from '../constants';

//########################## OBJECTS ##############################
const initialState = {
  id: null,
  name: null,
  children: null,
  isFetching: false,
  requestedAt: null,
  receivedAt: null
};

const requestTopologyObjects=(state,{objectId,requestedAt})=> {
  const options = {isFetching: true, requestedAt}

  if(!state.id) return {...options, id: objectId}

  return updateSubtrees(state, objectId, options)
}

const requestTopologyObjectsFailure=(state,{objectId}) => {
  const options = {isFetching: false}

  if(!state.id) return {...options, id: objectId}

  return updateSubtrees(state, objectId, options)
}

const receiveTopologyObjects=(state,{objectTopology,receivedAt, objectId})=> {
  const options = Object.assign(objectTopology, {isFetching: false, receivedAt})

  if(!state.id) return {...options}

  return updateSubtrees(state, objectId, options)
}

// const updateSubtrees = (state, objectId, options) => {
//   if (state.id == options.objectId) {
//     return Object.assign({}, state, options)
//   }
//   else if(state.children) {
//     for(let i in state.children) {
//       console.log('i',i)
//       state.children[i] = updateSubtrees(state.children[i], objectId, options)
//     }
//   } else return state
// }

const updateSubtrees = (node, id, options) => {
  if(node.id == id) {
    return Object.assign({}, node, options)
  } else if(node.children && node.children.length>0) {
    let newNode = {...node}
    for(let i in newNode.children) {
      newNode.children[i] = updateSubtrees(newNode.children[i], id, options)
    }
    return newNode
  } else return node
}

// entries reducer
export default (state, action) => {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_TOPOLOGY_OBJECTS: return receiveTopologyObjects(state,action);
    case constants.REQUEST_TOPOLOGY_OBJECTS: return requestTopologyObjects(state,action);
    case constants.REQUEST_TOPOLOGY_OBJECTS_FAILURE: return requestTopologyObjectsFailure(state,action);
    default: return state;
  }
};
