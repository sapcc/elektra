import * as constants from '../constants';

const initialMaiaState = {
  utilization: {
    data: null,
    wasRequested: false,
    isFetching: false,
  },
};

const requestShareUtilization = (state, action) => ({
  ...state,
  utilization: { data: null, wasRequested: true, isFetching: true },
});

const requestShareUtilizationFailure = (state, action) => ({
  ...state,
  utilization: { data: null, wasRequested: true, isFetching: false },
});

const receiveShareUtilization = (state, { data: prometheusResponse }) => {
  const data = {};
  for (const entry of prometheusResponse.result) {
    const { metric, share_id } = entry.metric;
    const value = parseFloat(entry.value[1]);
    data[share_id] = data[share_id] || {};
    data[share_id][metric] = value;
  }

  return {
    ...state,
    utilization: { data, wasRequested: true, isFetching: false },
  };
};

export const maia = (state, action) => {
  if (state == null) {
    state = initialMaiaState;
  }
  switch (action.type) {
    case constants.REQUEST_SHARE_UTILIZATION:
      return requestShareUtilization(state, action);
    case constants.REQUEST_SHARE_UTILIZATION_FAILURE:
      return requestShareUtilizationFailure(state, action);
    case constants.RECEIVE_SHARE_UTILIZATION:
      return receiveShareUtilization(state, action);
    default: return state;
  }
};
