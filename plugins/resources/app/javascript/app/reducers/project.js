import * as constants from '../constants';

const emptyData = {
  metadata: null,
  overview: null,
  services: null,
  resources: null,
}
const initialState = {
  id: null,
  ...emptyData,
  receivedAt: null,
  isFetching: false,
  syncStatus: null,
};

////////////////////////////////////////////////////////////////////////////////
// get project

const request = (state, {projectID, requestedAt}) => ({
  ...state,
  id: projectID,
  ...emptyData,
  isFetching: true,
  syncStatus: null,
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

  // `overview` is what the ProjectOverview component needs.
  const overview = {
    scrapedAt: Object.fromEntries(
      serviceList.map(srv => [ srv.type, srv.scraped_at ]),
    ),
  };
  const areas = {};
  for (let srv of serviceList) {
    areas[srv.area || srv.type] = [];
  }
  for (let srv of serviceList) {
    areas[srv.area || srv.type].push(srv.type);
  }
  overview.areas = areas;

  // `services` is what the ProjectService component needs.
  const services = {};
  for (let srv of serviceList) {
    var {resources: resourceList, ...serviceData} = srv;

    const categories = {};
    for (let res of resourceList) {
      categories[res.category || srv.type] = [];
    }
    for (let res of resourceList) {
      categories[res.category || srv.type].push(res.name);
    }
    serviceData.categories = categories;

    services[serviceData.type] = serviceData;
  }

  // `resources` is what the ProjectResource component needs.
  const resources = {};
  for (let srv of serviceList) {
    for (let res of srv.resources) {
      resources[`${srv.type}/${res.name}`] = res;
    }
  }

  return {
    ...state,
    id: projectData.id,
    metadata: metadata,
    overview: overview,
    services: services,
    resources: resources,
    isFetching: false,
    syncStatus: null,
    receivedAt,
  };
}

////////////////////////////////////////////////////////////////////////////////
// sync project

const mustMatchProjectID = (state, action, reducer) => {
  // ignore actions when the view has switched to a different project in the meantime
  if (action.projectID !== undefined && action.projectID !== state.id) {
    return state;
  }
  return reducer(state, action);
};

const syncProjectFailure = (state, action) => ({
  ...state,
  syncStatus: null,
});

const syncProjectRequested = (state, action) => ({
  ...state,
  syncStatus: 'requested',
});

const syncProjectStarted = (state, action) => ({
  ...state,
  syncStatus: 'started',
});

const syncProjectFinished = (state, action) => ({
  ...state,
  syncStatus: 'reloading',
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
    case constants.SYNC_PROJECT_REQUESTED:  return mustMatchProjectID(state, action, syncProjectRequested);
    case constants.SYNC_PROJECT_FAILURE:    return mustMatchProjectID(state, action, syncProjectFailure);
    case constants.SYNC_PROJECT_STARTED:    return mustMatchProjectID(state, action, syncProjectStarted);
    case constants.SYNC_PROJECT_FINISHED:   return mustMatchProjectID(state, action, syncProjectFinished);
    default: return state;
  }
};
