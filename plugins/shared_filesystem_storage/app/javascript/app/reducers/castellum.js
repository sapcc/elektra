import * as constants from '../constants';

const initialStateForPath = {
  data: null,
  errorMessage: null,
  isFetching: false,
  requestedAt: null,
  receivedAt: null,
};
const initialCastellumState = {
  'assets/nfs-shares': initialStateForPath,
  'resources/nfs-shares': initialStateForPath,
  'resources/nfs-shares/operations/pending': initialStateForPath,
  'resources/nfs-shares/operations/recently-succeeded': initialStateForPath,
  'resources/nfs-shares/operations/recently-failed': initialStateForPath,
};

const requestData = (state, {path, requestedAt}) => ({
  ...state,
  [path]: {
    ...initialStateForPath,
    isFetching: true,
    requestedAt,
  },
});

const requestDataFailure = (state, {path, message}) => ({
  ...state,
  [path]: {
    ...state[path],
    data: null,
    errorMessage: message,
    isFetching: false,
  },
});

const receiveData = (state, {path, data, receivedAt}) => ({
  ...state,
  [path]: {
    ...state[path],
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
    case constants.REQUEST_CASTELLUM_DATA: return requestData(state, action);
    case constants.RECEIVE_CASTELLUM_DATA: return receiveData(state, action);
    case constants.REQUEST_CASTELLUM_DATA_FAILURE: return requestDataFailure(state, action);
    default: return state;
  }
};
