// import * as constants from '../constants';
// import { pluginAjaxHelper } from 'ajax_helper';
//
// const ajaxHelper = pluginAjaxHelper('networking')
//
// const fetchNetworkStats= (params) =>
//   new Promise((handleSuccess,handleErrors) =>
//     ajaxHelper.get('/network_usage_stats', {params}).then( (response) => {
//       if (response.data.errors) {
//         handleErrors(response.data.errors)
//       } else {
//         handleSuccess(response.data.network_usage_stats)
//       }
//     }).catch( (error) => handleErrors(error.message))
//   )
// ;
//
// export {
//   fetchNetworkStats
// }


import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';

const ajaxHelper = pluginAjaxHelper('networking')

//################### NETWORKS #########################
const requestNetworkUsageStats= () =>
  ({
    type: constants.REQUEST_NETWORK_USAGE_STATS,
    requestedAt: Date.now()
  })
;

const requestNetworkUsageStatsFailure= () => ({type: constants.REQUEST_NETWORK_USAGE_STATS_FAILURE});

const receiveNetworkUsageStats= (json) =>
  ({
    type: constants.RECEIVE_NETWORK_USAGE_STATS,
    stats: json,
    receivedAt: Date.now()
  })
;

const fetchNetworkUsageStats= () =>
  function(dispatch,getState) {
    dispatch(requestNetworkUsageStats());

    return new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.get('/network_usage_stats').then( (response) => {
        if (response.data.errors) {
          dispatch(requestNetworkUsageStatsFailure())
          handleErrors(response.data.errors)
        } else {
          dispatch(receiveNetworkUsageStats(response.data.network_usage_stats))
          handleSuccess()
        }
      }).catch( (error) => {
        dispatch(requestNetworkUsageStatsFailure())
        handleErrors(error.message)
      })
    )
  }
;

const shouldFetchNetworkUsageStats= function(state) {
  if (state.network_usage_stats.isFetching || state.network_usage_stats.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchNetworkUsageStatsIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchNetworkUsageStats(getState())) { return dispatch(fetchNetworkUsageStats()); }
    else return Promise.resolve()
  }
;

export {
  fetchNetworkUsageStatsIfNeeded
}
