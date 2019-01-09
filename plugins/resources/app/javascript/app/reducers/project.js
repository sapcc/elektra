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
};

const request = (state, {projectID, requestedAt}) => ({
  ...state,
  id: projectID,
  ...emptyData,
  isFetching: true,
  requestedAt,
});

const requestFailure = (state, action) => ({
  ...state,
  isFetching: false,
});

const receive = (state, {projectData, receivedAt}) => {
  // This reducer takes the `projectData` returned by Limes and flattens it
  // into several structures that reflect the different levels of React
  // components.

  // `metadata` is what multiple levels need (e.g. bursting multiplier).
  var {services: serviceList, ...metadata} = projectData;

  // `overview` is what the ProjectOverview component needs.
  const allScrapedAt = serviceList.map(srv => srv.scraped_at);
  const overview = {
    minScrapedAt: Math.min(...allScrapedAt),
    maxScrapedAt: Math.max(...allScrapedAt),
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
    receivedAt,
  };
}

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
