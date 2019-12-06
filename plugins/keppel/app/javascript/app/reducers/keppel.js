import * as constants from '../constants';

const initialState = {
  accounts: {
    isFetching:  false,
    requestedAt: null,
    receivedAt:  null,
    data:        null,
  },
  repositoriesFor: {},
};

const initialRepositoriesState = {
  isFetching:  false,
  requestedAt: null,
  receivedAt:  null,
  data:        null,
};

const reqAccts = (state, {requestedAt}) => ({
  ...state,
  accounts: {
    ...initialState.accounts,
    isFetching: true,
    requestedAt,
  },
});

const reqAcctsFail = state => ({
  ...state,
  accounts: {
    ...state.accounts,
    isFetching: false,
  },
});

const recvAccts = (state, {data, receivedAt}) => ({
  ...state,
  accounts: {
    ...state.accounts,
    isFetching: false,
    data, receivedAt,
  },
});

const updateAcct = (state, {account}) => ({
  ...state,
  accounts: {
    ...state.accounts,
    data: [
      ...(state.accounts.data.filter(a => a.name != account.name)),
      account,
    ],
  },
});

const reqRepos = (state, {accountName, requestedAt}) => ({
  ...state,
  repositoriesFor: {
    ...state.repositoriesFor,
    [accountName]: {
      ...initialRepositoriesState,
      isFetching: true,
      requestedAt,
    },
  },
});

const reqReposFail = (state, {accountName}) => ({
  ...state,
  repositoriesFor: {
    ...state.repositoriesFor,
    [accountName]: {
      ...state.repositoriesFor[accountName],
      isFetching: false,
      data: null,
    },
  },
});

const recvRepos = (state, {accountName, data}) => ({
  ...state,
  repositoriesFor: {
    ...state.repositoriesFor,
    [accountName]: {
      ...state.repositoriesFor[accountName],
      data: [ ...(state.repositoriesFor[accountName].data || []), ...data ],
    },
  },
});

const recvReposDone = (state, {accountName, receivedAt}) => ({
  ...state,
  repositoriesFor: {
    ...state.repositoriesFor,
    [accountName]: {
      ...state.repositoriesFor[accountName],
      isFetching: false,
      receivedAt,
    },
  },
});

export const keppel = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch(action.type) {
    case constants.REQUEST_ACCOUNTS:         return reqAccts(state, action);
    case constants.REQUEST_ACCOUNTS_FAILURE: return reqAcctsFail(state);
    case constants.RECEIVE_ACCOUNTS:         return recvAccts(state, action);
    case constants.UPDATE_ACCOUNT:           return updateAcct(state, action);
    case constants.REQUEST_REPOSITORIES:          return reqRepos(state, action);
    case constants.REQUEST_REPOSITORIES_FAILURE:  return reqReposFail(state, action);
    case constants.RECEIVE_REPOSITORIES:          return recvRepos(state, action);
    case constants.REQUEST_REPOSITORIES_FINISHED: return recvReposDone(state, action);
    default: return state;
  }
};
