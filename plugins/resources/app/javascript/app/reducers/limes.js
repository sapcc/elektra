import * as constants from '../constants';
import { objectFromEntries } from '../polyfill';

const initialState = {
  //data from Limes
  metadata: null,
  overview: null,
  categories: null,
  //UI state
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  isIncomplete: false,
  syncStatus: null,

  autoscalableSubscopes: {
    //data from Limes
    bySrvAndRes: null,
    isEmpty: true,
    //UI state
    requestedAt: null,
    receivedAt: null,
    isFetching: false,
  },
};

////////////////////////////////////////////////////////////////////////////////
// get quota/usage data

const request = (state, {requestedAt}) => ({
  ...state,
  isFetching: true,
  isIncomplete: false,
  requestedAt,
});

const requestFailure = (state, action) => ({
  ...state,
  isFetching: false,
  syncStatus: null,
});

const receive = (state, {data, receivedAt}) => {
  // This reducer takes the `data` returned by Limes and flattens it
  // into several structures that reflect the different levels of React
  // components.

  // validation: check that each service has resources (we might see missing
  // resources immediately after project creation, before Limes has completed
  // the initial scrape of all project services)
  if (data.services.some(srv => (srv.resources || []).length == 0)) {
    return {
      ...state,
      receivedAt,
      isFetching: false,
      isIncomplete: true,
    };
  }

  // `metadata` is what multiple levels need (e.g. bursting multiplier).
  var {services: serviceList, ...metadata} = data;

  // `categories` is what the Category component needs.
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

  // `overview` is what the Overview component needs.
  const overview = {
    //This field is only filled for project scope, and {} otherwise.
    scrapedAt: objectFromEntries(
      serviceList.map(srv => [ srv.type, srv.scraped_at ]),
    ),
    //These two fields are only filled for cluster/domain scope, and {} otherwise.
    minScrapedAt: objectFromEntries(
      serviceList.map(srv => [ srv.type, srv.min_scraped_at ]),
    ),
    maxScrapedAt: objectFromEntries(
      serviceList.map(srv => [ srv.type, srv.max_scraped_at ]),
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
// discover autoscalable subscopes

const requestAutoscalableSubscopes = (state, {requestedAt}) => ({
  ...state,
  autoscalableSubscopes: {
    ...state.autoscalableSubscopes,
    isFetching: true,
    requestedAt,
  },
});

const requestAutoscalableSubscopesFailure = (state, action) => ({
  ...state,
  autoscalableSubscopes: {
    ...state.autoscalableSubscopes,
    isFetching: false,
  },
});

const receiveAutoscalableSubscopes = (state, {data, receivedAt}) => {
  const result = {};
  let isEmpty = true;

  //reorder data from scope/service/resource into service/resource/scope
  //for more convenient access
  for (const scope of data) {
    for (const srv of scope.services) {
      result[srv.type] = result[srv.type] || {};

      for (const res of srv.resources) {
        result[srv.type][res.name] = result[srv.type][res.name] || [];

        if ((res.annotations || {}).can_autoscale === 'true') {
          isEmpty = false;
          result[srv.type][res.name].push({
            id: scope.id,
            name: scope.name,
          });
        }
      }
    }
  }

  return {
    ...state,
    autoscalableSubscopes: {
      ...state.autoscalableSubscopes,
      bySrvAndRes: result,
      isEmpty,
      isFetching: false,
      receivedAt,
    },
  };
};

////////////////////////////////////////////////////////////////////////////////
// sync project

const setSyncStatus = (state, syncStatus) => ({
  ...state,
  syncStatus: syncStatus,
});

////////////////////////////////////////////////////////////////////////////////
// entrypoint

export const limes = (state, action) => {
  if (state == null) {
    state = initialState;
  }

  switch (action.type) {
    case constants.REQUEST_DATA:         return request(state, action);
    case constants.REQUEST_DATA_FAILURE: return requestFailure(state, action);
    case constants.RECEIVE_DATA:         return receive(state, action);
    case constants.SYNC_PROJECT_REQUESTED:  return setSyncStatus(state, 'requested');
    case constants.SYNC_PROJECT_FAILURE:    return setSyncStatus(state, null);
    case constants.SYNC_PROJECT_STARTED:    return setSyncStatus(state, 'started');
    case constants.SYNC_PROJECT_FINISHED:   return setSyncStatus(state, 'reloading');
    case constants.REQUEST_AUTOSCALABLE_SUBSCOPES:         return requestAutoscalableSubscopes(state, action);
    case constants.REQUEST_AUTOSCALABLE_SUBSCOPES_FAILURE: return requestAutoscalableSubscopesFailure(state, action);
    case constants.RECEIVE_AUTOSCALABLE_SUBSCOPES:         return receiveAutoscalableSubscopes(state, action);
    default: return state;
  }
};
