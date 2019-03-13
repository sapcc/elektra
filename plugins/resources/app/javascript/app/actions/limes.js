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

  //TODO domain level, cluster level
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

export const setQuota = (scopeData, limesRequestBody, elektraRequestBody) => function(dispatch) {
  const scope = new Scope(scopeData);

  //TODO: send elektraRequestBody if required
  //TODO: only send limesRequestBody if required
  return new Promise((resolve, reject) =>
    ajaxHelper.put(scope.urlPath(), limesRequestBody)
      .then((response) => {
        dispatch(fetchData(scopeData));
        resolve(response);
      }).catch(error => reject({ errors: limesErrorMessage(error) }))
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
