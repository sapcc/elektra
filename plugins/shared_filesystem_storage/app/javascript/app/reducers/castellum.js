import * as constants from '../constants';

const initialCastellumState = {
  resourceConfig: {
    data: null,
    errorMessage: null,
    isFetching: false,
    requestedAt: null,
    receivedAt: null,
  },
};

const requestResConf = (state, {requestedAt}) => ({
  ...state,
  resourceConfig: {
    ...initialCastellumState.resourceConfig,
    isFetching: true,
    requestedAt,
  },
});

const requestResConfFailure = (state, {message}) => ({
  ...state,
  resourceConfig: {
    ...state.resourceConfig,
    data: null,
    errorMessage: message,
    isFetching: false,
  },
});

const receiveResConf = (state, {data, receivedAt}) => ({
  ...state,
  resourceConfig: {
    ...state.resourceConfig,
    data,
    errorMessage: null,
    isFetching: false,
    receivedAt,
  },
});

export const castellum = (state, action) => {
  if (state == null) {
    state = initialCastellumState;
  }
  switch (action.type) {
    case constants.REQUEST_CASTELLUM_RESOURCE_CONFIG: return requestResConf(state, action);
    case constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG: return receiveResConf(state, action);
    case constants.REQUEST_CASTELLUM_RESOURCE_CONFIG_FAILURE: return requestResConfFailure(state, action);
    default: return state;
  }
};
