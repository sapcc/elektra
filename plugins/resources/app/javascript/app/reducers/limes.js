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

  capacityData: {
    //data from Limes
    metadata: null,
    overview: null,
    categories: null,
    availabilityZones: null,
    //UI state
    requestedAt: null,
    receivedAt: null,
    isFetching: false,
  },

  inconsistencyData: {
    //data from Limes
    data: null,
    //UI state
    requestedAt: null,
    receivedAt: null,
    isFetching: false,
  },
};

////////////////////////////////////////////////////////////////////////////////
// helper for reducers that need to restructure a Limes JSON into a triplet of
// (metadata, overview, categories)

const restructureReport = (data, resourceFilter = null) => {
  // This reducer helper takes the `data` returned by Limes under any GET
  // endpoint and flattens it into several structures that reflect the
  // different levels of React components.
  //
  // Note that the outermost level of the JSON (containing only the key
  // "cluster", "domain" or "project") has already been removed in the
  // fetchData/fetchCapacity action.
  //
  // If `resourceFilter` is given, only resources matching this attribute are
  // included in the final result. (Services and categories without any
  // matching resources are removed from the result.)

  // `metadata` is what multiple levels need (e.g. bursting multiplier).
  var {services: serviceList, ...metadata} = data;

  //apply `resourceFilter`
  if (resourceFilter !== null) {
    serviceList = serviceList.map(srv => ({
      ...srv,
      resources: srv.resources.filter(resourceFilter),
    })).filter(srv => srv.resources.length > 0);
  }

  // `categories` is what the Category component needs.
  const categories = {};
  for (let srv of serviceList) {
    const {resources: resourceList, type: serviceType, ...serviceData} = srv;

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
  // e.g. groupKeys(["foo", 1], ["bar", 2], ["foo", 3])
  //      = { foo: [1, 3], bar: [2] }
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

  return { metadata, categories, overview };
}

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

  return {
    ...state,
    ...restructureReport(data),
    isFetching: false,
    syncStatus: null,
    receivedAt,
  };
}

////////////////////////////////////////////////////////////////////////////////
// get capacity data for the cluster level

const requestCapacity = (state, {requestedAt}) => ({
  ...state,
  capacityData: {
    ...initialState.capacityData,
    isFetching: true,
    requestedAt,
  },
});

const requestCapacityFailure = (state, action) => ({
  ...state,
  capacityData: {
    ...state.capacityData,
    isFetching: false,
  },
});

const receiveCapacity = (state, { data, receivedAt }) => {
  const resourceFilter = res => {
    //skip sharev2/share_snapshots and sharev2/shares: Limes cannot
    //report usage for those, which makes them useless for the AZ overview UI
    if (res.name == 'shares' || res.name == 'share_snapshots') {
      return false;
    }
    return res.per_availability_zone !== undefined;
  };
  const { metadata, categories, overview } = restructureReport(data, resourceFilter);

  //The AvailabilityZoneCategory component needs a list of all AZs to render
  //the AZ table consistently across all categories.
  const availabilityZones = {};
  for (const categoryName in categories) {
    for (const resource of categories[categoryName].resources) {
      for (const azCapacity of resource.per_availability_zone) {
        availabilityZones[azCapacity.name] = true;
      }
    }
  }

  return {
    ...state,
    capacityData: {
      ...state.capacityData,
      metadata, categories, overview,
      availabilityZones: Object.keys(availabilityZones).sort(),
      isFetching: false,
      receivedAt,
    },
  };

};

////////////////////////////////////////////////////////////////////////////////
// get inconsistency data

const requestInconsistencies = (state, {requestedAt}) => ({
  ...state,
  inconsistencyData: {
    ...initialState.inconsistencyData,
    isFetching: true,
    requestedAt,
  },
});

const requestInconsistenciesFailure = (state, action) => ({
  ...state,
  inconsistencyData: {
    ...state.inconsistencyData,
    isFetching: false,
  },
});

const receiveInconsistencies = (state, { data, receivedAt }) => ({
  ...state,
  inconsistencyData: {
    ...state.inconsistencyData,
    data,
    isFetching: false,
    receivedAt,
  },
});

////////////////////////////////////////////////////////////////////////////////
// discover autoscalable subscopes

const requestAutoscalableSubscopes = (state, {requestedAt}) => ({
  ...state,
  autoscalableSubscopes: {
    ...initialState.autoscalableSubscopes,
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

const receiveAutoscalableSubscopes = (state, {bySrvAndRes, isEmpty, receivedAt}) => ({
  ...state,
  autoscalableSubscopes: {
    ...state.autoscalableSubscopes,
    bySrvAndRes,
    isEmpty,
    isFetching: false,
    receivedAt,
  },
});

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
    case constants.REQUEST_CAPACITY:         return requestCapacity(state, action);
    case constants.REQUEST_CAPACITY_FAILURE: return requestCapacityFailure(state, action);
    case constants.RECEIVE_CAPACITY:         return receiveCapacity(state, action);
    case constants.REQUEST_INCONSISTENCIES:         return requestInconsistencies(state, action);
    case constants.REQUEST_INCONSISTENCIES_FAILURE: return requestInconsistenciesFailure(state, action);
    case constants.RECEIVE_INCONSISTENCIES:         return receiveInconsistencies(state, action);
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
