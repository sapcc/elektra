const initialState = {
  trees: [],
  unassignedTreeErrorCount: 0,
  unassignedTreeError: null,
}

const request = (state) => {
  console.log("statusTrees request")
  return state
}

const receive = (state, { lbId, tree }) => {
  console.log("statusTrees receive")
  const index = state.trees.findIndex((item) => item.id == tree.loadbalancer.id)
  const trees = state.trees.slice()
  const newTreeState = {
    ...tree.loadbalancer,
    errorCount: 0,
    error: null,
    updatedAt: Date.now(),
  }
  if (index >= 0) {
    trees[index] = newTreeState
  } else {
    trees.push(newTreeState)
  }
  return { ...state, trees: trees }
}

const requestFailure = (state, { lbId, error }) => {
  console.log("statusTree request failure")
  const index = state.trees.findIndex((item) => item.id == lbId)
  const trees = state.trees.slice()
  let unassignedTreeErrorCount = state.unassignedTreeErrorCount
  let unassignedTreeError = state.unassignedTreeError
  if (index >= 0) {
    const errorCount = trees[index].errorCount || 0
    console.log("errorCount-->", errorCount)
    trees[index] = {
      ...trees[index],
      errorCount: errorCount + 1,
      error: error,
      updatedAt: Date.now(),
    }
  } else {
    unassignedTreeErrorCount = unassignedTreeErrorCount + 1
    unassignedTreeError = error
  }
  return {
    ...state,
    trees: trees,
    unassignedTreeErrorCount: unassignedTreeError,
    unassignedTreeError: unassignedTreeError,
  }
}

export default (state = initialState, action) => {
  switch (action.type) {
    case "REQUEST_LB_STATUS_TREE":
      return request(state, action)
    case "RECEIVE_LB_STATUS_TREE":
      return receive(state, action)
    case "REQUEST_LB_STATUS_TREE_FAILURE":
      return requestFailure(state, action)
    default:
      return state
  }
}
