import * as constants from '../constants';
import { ajaxHelper, pluginAjaxHelper } from 'ajax_helper';
import { addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

import { Scope } from '../scope';

const limesErrorMessage = (error) =>
  error.response && error.response.data ||
  error.message

const showLimesError = (error) =>
  addError(React.createElement(ErrorsList, {
    errors: limesErrorMessage(error)
  }))

////////////////////////////////////////////////////////////////////////////////
// get quota/usage data

const requestData = () => ({
  type: constants.REQUEST_DATA,
  requestedAt: Date.now(),
});

const requestDataFailure = () => ({
  type: constants.REQUEST_DATA_FAILURE,
});

const receiveData = (json) => ({
  type: constants.RECEIVE_DATA,
  data: json,
  receivedAt: Date.now(),
});

export const fetchData = (scopeData) => function(dispatch, getState) {
  dispatch(requestData());
  const scope = new Scope(scopeData);

  return ajaxHelper.get(scope.urlPath())
    .then((response) => {
      dispatch(receiveData(response.data[scope.level()]));
    })
    .catch((error) => {
      dispatch(requestDataFailure());
      showLimesError(error);
    });
};

export const fetchDataIfNeeded = (scopeData) => function(dispatch, getState) {
  const state = getState();
  if (state.limes.isFetching || state.limes.requestedAt) {
    return;
  }
  return dispatch(fetchData(scopeData));
};

////////////////////////////////////////////////////////////////////////////////
// get quota/usage data for projects (in domain scope) or domains (in cluster scope)

export const listSubscopes = (scopeData, serviceType, resourceName) => function(dispatch, getState) {
  const scope = new Scope(scopeData);
  const url = scope.subscopesUrlPath();
  const resultKey = url.split('/').pop();
  const queryString = `?service=${serviceType}&resource=${resourceName}`;

  return new Promise((resolve, reject) =>
    ajaxHelper.get(url + queryString)
      .then(response => resolve(response.data[resultKey]))
      .catch(error => reject({ errors: limesErrorMessage(error) }))
  );
};

////////////////////////////////////////////////////////////////////////////////
// get quota/usage data for all clusters

export const listClusters = (serviceType, resourceName) => function(dispatch, getState) {
  const url = `/v1/clusters?local&service=${serviceType}&resource=${resourceName}`;

  return new Promise((resolve, reject) =>
    ajaxHelper.get(url)
      .then(response => resolve(response.data))
      .catch(error => reject({ errors: limesErrorMessage(error) }))
  );
}

////////////////////////////////////////////////////////////////////////////////
// sync project

const syncProjectFailure = () => ({
  type: constants.SYNC_PROJECT_FAILURE,
});

const syncProjectRequested = () => ({
  type: constants.SYNC_PROJECT_REQUESTED,
});

const syncProjectStarted = () => ({
  type: constants.SYNC_PROJECT_STARTED,
});

const syncProjectFinished = () => ({
  type: constants.SYNC_PROJECT_FINISHED,
});

export const syncProject = ({domainID, projectID}) => function(dispatch, getState) {
  dispatch(syncProjectRequested());
  ajaxHelper.post(`/v1/domains/${domainID}/projects/${projectID}/sync`)
    .then((response) => {
      dispatch(syncProjectStarted());
    })
    .catch((error) => {
      dispatch(syncProjectFailure());
      showLimesError(error);
    });
};

export const pollRunningSyncProject = ({domainID, projectID}) => function(dispatch, getState) {
  //check the scraped_at timestamps of all project services to see if the
  //running sync has completed
  ajaxHelper.get(`/v1/domains/${domainID}/projects/${projectID}`, { resource: 'none' })
    .catch((error) => {
      dispatch(syncProjectFailure());
      showLimesError(error);
    })
    .then((response) => {
      const oldServices = (getState().limes.overview || {}).scrapedAt || {};
      const newServices = ((response.data.project || {}).services || []);
      let allUpdated = true; //until proven otherwise
      for (const srv of newServices) {
        const oldScrapedAt = oldServices[srv.type] || 0;
        const newScrapedAt = srv.scraped_at || 0;
        if (newScrapedAt <= oldScrapedAt) {
          allUpdated = false;
        }
      }

      // when polling shows that all project services have been synced, reload
      // the project in the UI (this will also break the polling since the
      // polling is done by a React component which vanishes during the project
      // reload)
      if (allUpdated) {
        dispatch(syncProjectFinished());
        dispatch(fetchData({domainID, projectID}));
      }
    });
};

////////////////////////////////////////////////////////////////////////////////
// enable/disable bursting

export const setProjectHasBursting = ({domainID, projectID, hasBursting}) => function(dispatch) {
  var requestBody = { "project": { "bursting": { "enabled": hasBursting ? true : false }}};
  return new Promise((resolve, reject) =>
    ajaxHelper.put(`/v1/domains/${domainID}/projects/${projectID}`, requestBody)
      .then((response) => {
        dispatch(fetchData({ domainID, projectID }));
        resolve();
      }).catch(error => reject({ errors: limesErrorMessage(error) }))
  )
}

////////////////////////////////////////////////////////////////////////////////
// edit quota

export const setQuota = (scopeData, requestBody) => function(dispatch) {
  const scope = new Scope(scopeData);

  return new Promise((resolve, reject) =>
    ajaxHelper.put(scope.urlPath(), requestBody)
      .then(resolve)
      .catch(error => reject({ errors: limesErrorMessage(error) }))
  );
};

export const simulateSetQuota = (scopeData, requestBody) => function(dispatch) {
  const scope = new Scope(scopeData);

  return new Promise((resolve, reject) =>
    ajaxHelper.post(scope.urlPath() + '/simulate-put', requestBody)
      .then(resolve)
      .catch(error => reject({ errors: limesErrorMessage(error) }))
  );
};

////////////////////////////////////////////////////////////////////////////////
// autoscaling

const discoverAutoscalableSubscopes = (scopeData) => (dispatch) => {
  const scope = new Scope(scopeData);
  if (!scope.canAutoscaleSubscopes()) {
    return;
  }
  const url = scope.subscopesUrlPath();
  const resultKey = url.split('/').pop();

  dispatch({
    type: constants.REQUEST_AUTOSCALABLE_SUBSCOPES,
    requestedAt: Date.now(),
  });

  return ajaxHelper.get(url)
    .then((response) => {
      dispatch({
        type: constants.RECEIVE_AUTOSCALABLE_SUBSCOPES,
        data: response.data[resultKey],
        receivedAt: Date.now(),
      });
    })
    .catch((error) => {
      dispatch({
        type: constants.REQUEST_AUTOSCALABLE_SUBSCOPES_FAILURE,
      });
      showLimesError(error);
    });
};

export const discoverAutoscalableSubscopesIfNeeded = (scopeData) => (dispatch, getState) => {
  const scope = new Scope(scopeData);
  if (!scope.canAutoscaleSubscopes()) {
    return;
  }

  const state = getState().limes.autoscalableSubscopes;
  if (state.isFetching || state.requestedAt) {
    return;
  }
  return dispatch(discoverAutoscalableSubscopes(scopeData));
};
