import * as constants from '../constants';

const initialState = {
  id: null,
  data: null,
  receivedAt: null,
  isFetching: false,
};

const request = (state, {projectID, requestedAt}) => ({
  ...state,
  id: projectID,
  data: null,
  isFetching: true,
  requestedAt,
});

const requestFailure = (state, action) => ({
  ...state,
  isFetching: false,
});

const receive = (state, {projectData, receivedAt}) => ({
  ...state,
  id: projectData.id,
  data: projectData,
  isFetching: false,
  receivedAt,
});

export const project = (state, action) => {
  if (state == null) {
    state = initialState;
  }
  switch (action.type) {
    case constants.REQUEST_PROJECT:         return request(state, action);
    case constants.REQUEST_PROJECT_FAILURE: return requestFailure(state, action);
    case constants.RECEIVE_PROJECT:         return receive(state, action);
    default: return state;
  }
};
