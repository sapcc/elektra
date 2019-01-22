import * as constants from '../constants';

const initialState = {
  //data from Limes
  metadata: null,
  overview: null,
  categories: null,
  //UI state
  receivedAt: null,
  isFetching: false,
  syncStatus: null,
};

////////////////////////////////////////////////////////////////////////////////
// get project

const request = (state, {projectID, requestedAt}) => ({
  ...state,
  isFetching: true,
  requestedAt,
});

const requestFailure = (state, action) => ({
  ...state,
  isFetching: false,
  syncStatus: null,
});

const receive = (state, {projectData, receivedAt}) => {
  // This reducer takes the `projectData` returned by Limes and flattens it
  // into several structures that reflect the different levels of React
  // components.

  // `metadata` is what multiple levels need (e.g. bursting multiplier).
  var {services: serviceList, ...metadata} = projectData;

  // `categories` is what the ProjectCategory component needs.
  const categories = {};
  for (let srv of serviceList) {
    var {resources: resourceList, type: serviceType, ...serviceData} = srv;

    for (let res of resourceList) {
      categories[res.category || serviceType] = {
        serviceType,
        ...serviceData,
        resources: [],
      };
    }
    for (let res of resourceList) {
      categories[res.category || serviceType].resources.push(res);
    }
  }

  // helper function: groupKeys transforms a list of key-value pairs into an
  // object just like Object.fromEntries(), but allows duplicate keys by
  // producing arrays of values
  // 
  // e.g. groupKeys(["foo", 1], ["foo", 2], ["foo", 3])
  //      = { foo: [1, 3], bar: 2 }
  const groupKeys = (entries) => {
    const result = {};
    for (let [k, v] of entries) { result[k] = []; }
    for (let [k, v] of entries) { result[k].push(v); }
    return result;
  };

  // `overview` is what the ProjectOverview component needs.
  const overview = {
    scrapedAt: Object.fromEntries(
      serviceList.map(srv => [ srv.type, srv.scraped_at ]),
    ),
    areas: groupKeys(serviceList.map((srv) => [ srv.area || srv.type, srv.type ])),
    categories: groupKeys(Object.entries(categories).map(([ catName, cat ]) => [ cat.serviceType, catName ])),
  };

  return {
    ...state,
    metadata: metadata,
    overview: overview,
    categories: categories,
    isFetching: false,
    syncStatus: null,
    receivedAt,
  };
}

////////////////////////////////////////////////////////////////////////////////
// sync project

const setSyncStatus = (state, action, syncStatus) => ({
  ...state,
  syncStatus: syncStatus,
});

////////////////////////////////////////////////////////////////////////////////
// entrypoint

export const project = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch (action.type) {
    case constants.REQUEST_PROJECT:         return request(state, action);
    case constants.REQUEST_PROJECT_FAILURE: return requestFailure(state, action);
    case constants.RECEIVE_PROJECT:         return receive(state, action);
    case constants.SYNC_PROJECT_REQUESTED:  return setSyncStatus(state, action, 'requested');
    case constants.SYNC_PROJECT_FAILURE:    return setSyncStatus(state, action, null);
    case constants.SYNC_PROJECT_STARTED:    return setSyncStatus(state, action, 'started');
    case constants.SYNC_PROJECT_FINISHED:   return setSyncStatus(state, action, 'reloading');
    default: return state;
  }
};
