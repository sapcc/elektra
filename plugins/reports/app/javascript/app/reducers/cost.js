import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestCostReport= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true, data: null, error: null};
};

const receiveCostReport= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false, error: null};
};

const requestCostReportFailure= function(state, error) {
  return {...state, error, isFetching: false, data: null};
};

export const cost = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_COST_REPORT: return requestCostReport(state,action);
    case constants.REQUEST_COST_REPORT_FAILURE: return requestCostReportFailure(state,action);
    case constants.RECEIVE_COST_REPORT: return receiveCostReport(state,action);

    default: return state;
  }
};
