import * as constants from '../constants';

//########################## NETWORKS ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestNetworkUsageStats=(state,{requestedAt})=> (
  {... state, isFetching: true, requestedAt}
)

const requestNetworkUsageStatsFailure = (state,...rest) => (
  {... state, isFetching: false}
)

const receiveNetworkUsageStats=(state,{stats,receivedAt}) => (
  {... state, isFetching: false, items: stats, receivedAt}
)

export default (state, action) => {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.RECEIVE_NETWORK_USAGE_STATS: return receiveNetworkUsageStats(state,action);
    case constants.REQUEST_NETWORK_USAGE_STATS: return requestNetworkUsageStats(state,action);
    case constants.REQUEST_NETWORK_USAGE_STATS_FAILURE: return requestNetworkUsageStatsFailure(state,action);
    default: return state;
  }
};
