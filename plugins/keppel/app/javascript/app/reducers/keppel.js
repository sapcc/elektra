import * as constants from '../constants';

const initialState = {
  accounts: {
    isFetching:  false,
    requestedAt: null,
    receivedAt:  null,
    data:        null,
  },
  peers: {
    isFetching:  false,
    requestedAt: null,
    receivedAt:  null,
    data:        null,
  },
  repositoriesFor: {},
  manifestsFor: {},
};

const initialRepositoriesState = {
  isFetching:  false,
  requestedAt: null,
  receivedAt:  null,
  data:        null,
};

const initialManifestsState = {
  isFetching:  false,
  requestedAt: null,
  receivedAt:  null,
  data:        null,
};

////////////////////////////////////////////////////////////////////////////////
// accounts

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

////////////////////////////////////////////////////////////////////////////////
// peers

const reqPeers = (state, {requestedAt}) => ({
  ...state,
  peers: {
    ...initialState.peers,
    isFetching: true,
    requestedAt,
  },
});

const reqPeersFail = state => ({
  ...state,
  peers: {
    ...state.peers,
    isFetching: false,
  },
});

const recvPeers = (state, {data, receivedAt}) => ({
  ...state,
  peers: {
    ...state.peers,
    isFetching: false,
    data, receivedAt,
  },
});

////////////////////////////////////////////////////////////////////////////////
// repositories

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

const deleteRepo = (state, {accountName, repoName}) => ({
  ...state,
  repositoriesFor: {
    ...state.repositoriesFor,
    [accountName]: {
      ...state.repositoriesFor[accountName],
      data: (state.repositoriesFor[accountName].data || []).filter(r => r.name != repoName),
    },
  },
});

////////////////////////////////////////////////////////////////////////////////
// manifests

const updateManifestsFor = (state, accountName, repoName, update) => {
  const manifestsForAccount = state.manifestsFor[accountName] || {};
  return {
    ...state,
    manifestsFor: {
      ...state.manifestsFor,
      [accountName]: {
        ...manifestsForAccount,
        [repoName]: update(manifestsForAccount[repoName] || {}),
      },
    },
  };
};

const reqManifests = (state, {accountName, repoName, requestedAt}) => (
  updateManifestsFor(state, accountName, repoName, oldState => ({
    ...initialManifestsState,
    isFetching: true,
    requestedAt,
  }))
);

const reqManifestsFail = (state, {accountName, repoName}) => (
  updateManifestsFor(state, accountName, repoName, oldState => ({
    ...oldState,
    isFetching: false,
    data: null,
  }))
);

const recvManifests = (state, {accountName, repoName, data}) => (
  updateManifestsFor(state, accountName, repoName, oldState => ({
    ...oldState,
    data: [ ...(oldState.data || []), ...data ],
  }))
);

const recvManifestsDone = (state, {accountName, repoName, receivedAt}) => (
  updateManifestsFor(state, accountName, repoName, oldState => ({
    ...oldState,
    isFetching: false,
    receivedAt,
  }))
);

const deleteManifest = (state, {accountName, repoName, digest}) => (
  updateManifestsFor(state, accountName, repoName, oldState => ({
    ...oldState,
    data: (oldState.data || []).filter(m => m.digest != digest),
  }))
);

////////////////////////////////////////////////////////////////////////////////

export const keppel = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch(action.type) {
    case constants.REQUEST_ACCOUNTS:         return reqAccts(state, action);
    case constants.REQUEST_ACCOUNTS_FAILURE: return reqAcctsFail(state);
    case constants.RECEIVE_ACCOUNTS:         return recvAccts(state, action);
    case constants.UPDATE_ACCOUNT:           return updateAcct(state, action);
    case constants.REQUEST_PEERS:         return reqPeers(state, action);
    case constants.REQUEST_PEERS_FAILURE: return reqPeersFail(state);
    case constants.RECEIVE_PEERS:         return recvPeers(state, action);
    case constants.REQUEST_REPOSITORIES:          return reqRepos(state, action);
    case constants.REQUEST_REPOSITORIES_FAILURE:  return reqReposFail(state, action);
    case constants.RECEIVE_REPOSITORIES:          return recvRepos(state, action);
    case constants.REQUEST_REPOSITORIES_FINISHED: return recvReposDone(state, action);
    case constants.DELETE_REPOSITORY:             return deleteRepo(state, action);
    case constants.REQUEST_MANIFESTS:          return reqManifests(state, action);
    case constants.REQUEST_MANIFESTS_FAILURE:  return reqManifestsFail(state, action);
    case constants.RECEIVE_MANIFESTS:          return recvManifests(state, action);
    case constants.REQUEST_MANIFESTS_FINISHED: return recvManifestsDone(state, action);
    case constants.DELETE_MANIFEST:            return deleteManifest(state, action);
    default: return state;
  }
};
