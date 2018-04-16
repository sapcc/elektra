import * as constants from '../constants';

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null
};

const requestDomain= function(state,{requestedAt}) {
  return {...state, requestedAt, isFetching: true, data: null, error: null};
};

const receiveDomain= function(state,{data, receivedAt}) {
  return {...state, data, receivedAt, isFetching: false, error: null};
};

const requestDomainFailure= function(state, error) {
  return {...state, error, isFetching: false, data: null};
};

const resetDomain= (state, {}) => ({...initialState})

export const domain = function(state, action) {
  if (state == null) { state = initialState; }
  switch (action.type) {
    case constants.REQUEST_DOMAIN: return requestDomain(state,action);
    case constants.REQUEST_DOMAIN_FAILURE: return requestDomainFailure(state,action);
    case constants.RECEIVE_DOMAIN: return receiveDomain(state,action);
    case constants.RESET_STORE: return resetDomain(state,action);

    default: return state;
  }
};
