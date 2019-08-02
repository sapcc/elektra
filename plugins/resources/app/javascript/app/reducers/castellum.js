import * as constants from '../constants';

const initialState = {
  projectConfigs: {},
};

const initialProjectConfigState = {
  data: null,
  isFetching: false,
  requestedAt: null,
  receivedAt: null,
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

////////////////////////////////////////////////////////////////////////////////
// entrypoint

export const castellum = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch (action.type) {
    case constants.REQUEST_CASTELLUM_CONFIG:         return requestConfig(state, action);
    case constants.REQUEST_CASTELLUM_CONFIG_FAILURE: return requestConfigFailure(state, action);
    case constants.RECEIVE_CASTELLUM_CONFIG:         return receiveConfig(state, action);
    default: return state;
  }
};
