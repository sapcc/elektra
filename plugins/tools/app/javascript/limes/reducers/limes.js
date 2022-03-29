import * as constants from '../constants';

const initialErrorsState = {
  isFetching:   false,
  requestedAt:  null,
  receivedAt:   null,
  data:         null,
  errorMessage: null,
};

const makeInitialState = () => {
  const state = {};
  for (const errorType of constants.LIMES_ERROR_TYPES) {
    state[errorType] = initialErrorsState;
  }
  return state;
};

const reqErrors = (state, {errorType, requestedAt}) => ({
  ...state,
  [errorType]: {
    ...initialErrorsState,
    isFetching: true,
    requestedAt,
  },
});

const reqErrorsFail = (state, {errorType, errorMessage}) => ({
  ...state,
  [errorType]: {
    ...state[errorType],
    isFetching: false,
    errorMessage,
  },
});

const recvErrors = (state, {errorType, data, receivedAt}) => ({
  ...state,
  [errorType]: {
    ...state[errorType],
    isFetching: false,
    data, receivedAt,
  },
});

export const limes = (state, action) => {
  if (state == null) {
    state = makeInitialState();
  }

  switch (action.type) {
    case constants.REQUEST_LIMES_ERRORS:         return reqErrors(state, action);
    case constants.REQUEST_LIMES_ERRORS_FAILURE: return reqErrorsFail(state, action);
    case constants.RECEIVE_LIMES_ERRORS:         return recvErrors(state, action);
    default: return state;
  }
}
