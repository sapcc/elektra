import * as constants from '../constants';

const initialProjectConfigState = {
  data: null,
  isFetching: false,
  requestedAt: null,
  receivedAt: null,
};

const initialOperationsReportState = {
  data: null,
  errorMessage: null,
  isFetching: false,
  requestedAt: null,
  receivedAt: null,
};

const initialState = {
  projectConfigs: {},
  operationsReports: {
    "pending": initialOperationsReportState,
    "recently-failed": initialOperationsReportState,
    "recently-succeeded": initialOperationsReportState,
  },
};

////////////////////////////////////////////////////////////////////////////////
// get/set config

const requestConfig = (state, {projectID, requestedAt}) => ({
  ...state,
  projectConfigs: {
    ...state.projectConfigs,
    [projectID]: {
      ...initialProjectConfigState,
      isFetching: true,
      requestedAt,
    },
  },
});

const requestConfigFailure = (state, {projectID}) => ({
  ...state,
  projectConfigs: {
    ...state.projectConfigs,
    [projectID]: {
      ...state.projectConfigs[projectID],
      isFetching: false,
    },
  },
});

const receiveConfig = (state, {projectID, data, receivedAt}) => ({
  ...state,
  projectConfigs: {
    ...state.projectConfigs,
    [projectID]: {
      ...state.projectConfigs[projectID],
      isFetching: false,
      data, receivedAt,
    },
  },
});

const receiveResourceConfig = (state, {projectID, assetType, data, receivedAt}) => ({
  ...state,
  projectConfigs: {
    ...state.projectConfigs,
    [projectID]: {
      ...state.projectConfigs[projectID],
      data: {
        ...state.projectConfigs[projectID].data,
        [assetType]: data,
      },
      isFetching: false,
      receivedAt,
    },
  },
});

////////////////////////////////////////////////////////////////////////////////
// operations reports

const requestOperationsReport = (state, {reportType, requestedAt}) => ({
  ...state,
  operationsReports: {
    ...state.operationsReports,
    [reportType]: {
      ...initialOperationsReportState,
      isFetching: true,
      requestedAt,
    },
  },
});

const requestOperationsReportFailure = (state, {reportType, message, receivedAt}) => ({
  ...state,
  operationsReports: {
    ...state.operationsReports,
    [reportType]: {
      ...state.operationsReports[reportType],
      errorMessage: message,
      isFetching: false,
      receivedAt,
    },
  },
});

const receiveOperationsReport = (state, {reportType, data, receivedAt}) => ({
  ...state,
  operationsReports: {
    ...state.operationsReports,
    [reportType]: {
      ...state.operationsReports[reportType],
      data,
      isFetching: false,
      receivedAt,
    },
  },
});


////////////////////////////////////////////////////////////////////////////////
// entrypoint

export const castellum = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch (action.type) {
    case constants.REQUEST_CASTELLUM_CONFIG:          return requestConfig(state, action);
    case constants.REQUEST_CASTELLUM_CONFIG_FAILURE:  return requestConfigFailure(state, action);
    case constants.RECEIVE_CASTELLUM_CONFIG:          return receiveConfig(state, action);
    case constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG: return receiveResourceConfig(state, action);

    case constants.REQUEST_CASTELLUM_OPERATIONS_REPORT:         return requestOperationsReport(state, action);
    case constants.REQUEST_CASTELLUM_OPERATIONS_REPORT_FAILURE: return requestOperationsReportFailure(state, action);
    case constants.RECEIVE_CASTELLUM_OPERATIONS_REPORT:         return receiveOperationsReport(state, action);
    default: return state;
  }
};
