import * as constants from '../../constants';

//########################## CLUSTERS ##############################
const initialClusterState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestClusters=(state,{requestedAt})=>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestClustersFailure=function(state,...rest){
  const obj = rest[0];
  return Object.assign({},state,{isFetching: false});
};

const receiveClusters=(state,{clusters,receivedAt}) => {
  return Object.assign({},state,{
    isFetching: false,
    items: clusters,
    receivedAt
  })
};




// clusters reducer
export const clusters = function(state, action) {
  if (state == null) { state = initialClusterState; }
  switch (action.type) {
    case constants.RECEIVE_CLUSTERS:         return receiveClusters(state,action);
    case constants.REQUEST_CLUSTERS:         return requestClusters(state,action);
    case constants.REQUEST_CLUSTERS_FAILURE: return requestClustersFailure(state,action);

    default: return state;
  }
};
