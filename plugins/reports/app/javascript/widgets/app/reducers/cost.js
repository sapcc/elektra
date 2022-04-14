import * as constants from '../constants';

const initialState = {
  data: null,
  serviceMap: null,
  services: null,
  chartData: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const calcServiceMap= function(state,{serviceMap}) {
  return {...state, serviceMap};
};

const calcServices= function(state,{services}) {
  return {...state, services};
};

const calcChartData= function(state,{chartData}) {
  return {...state, chartData};
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
    case constants.CALC_SERVICE_MAP_COST_REPORT: return calcServiceMap(state,action);
    case constants.CALC_SERVICES_COST_REPORT: return calcServices(state,action);
    case constants.CALC_CHARTDATA_COST_REPORT: return calcChartData(state,action);
    case constants.REQUEST_COST_REPORT_FAILURE: return requestCostReportFailure(state,action);
    case constants.RECEIVE_COST_REPORT: return receiveCostReport(state,action);

    default: return state;
  }
};
