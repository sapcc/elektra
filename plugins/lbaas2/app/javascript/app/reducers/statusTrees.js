const initialState = {
  trees:[]
}

const request = (state) => {
  return state
}

const receive = (state, {lbId, tree}) => {

  console.log("tree-->", tree)

  const index = state.trees.findIndex((item) => item.id==tree.loadbalancer.id);
  const trees = state.trees.slice();
  const newTreeState = {...tree.loadbalancer, errorCount:0, error: null, updatedAt: Date.now()}
  // update or add
  if (index>=0) { 
    trees[index]= newTreeState; 
  } else { 
    trees.push(newTreeState); 
  }

  return {...state,
    trees: trees
  }
}

const requestFailure = (state, {lbId, error}) => {
  const index = state.trees.findIndex((item) => item.id==lbId);
  const trees = state.trees.slice();
  if (index>=0) { 
    trees[index] = {...trees[index], coerrorCount: trees[index].count +1, error: error, updatedAt: Date.now()}
  }
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'REQUEST_LB_STATUS_TREE':
      return request(state,action)
    case 'RECEIVE_LB_STATUS_TREE':
      return receive(state,action)      
    case 'REQUEST_LB_STATUS_TREE_FAILURE':
      return requestFailure(state,action)
    default:
      return state
  }
}