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

const receiveShareUtilization = (state, {data}) => ({
  ...state,
  utilization: { data, wasRequested: true, isFetching: false },
});

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
