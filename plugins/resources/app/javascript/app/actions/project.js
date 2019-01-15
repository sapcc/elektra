import * as constants from '../constants';
import { ajaxHelper, pluginAjaxHelper } from 'ajax_helper';
import { addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

// the `ajaxHelper` is set up in init.js to talk to the Limes API, so we need a
// separate AJAX helper for talking to Elektra
const elektraAjaxHelper = pluginAjaxHelper('resources', {
  headers: {'X-Requested-With': 'XMLHttpRequest'},
});

const elektraErrorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message

const limesErrorMessage = (error) =>
  error.response && error.response.data ||
  error.message

const showLimesError = (error) =>
  addError(React.createElement(ErrorsList, {
    errors: limesErrorMessage(error)
  }))

////////////////////////////////////////////////////////////////////////////////
// get project

const requestProject = (projectID) => ({
  type: constants.REQUEST_PROJECT,
  projectID,
  requestedAt: Date.now(),
});

const requestProjectFailure = (projectID) => ({
  type: constants.REQUEST_PROJECT_FAILURE,
  projectID,
});

const receiveProject = (json) => ({
  type: constants.RECEIVE_PROJECT,
  projectData: json,
  receivedAt: Date.now(),
});

export const fetchProject = ({domainID, projectID}) => function(dispatch, getState) {
  dispatch(requestProject(projectID));

  return ajaxHelper.get(`/v1/domains/${domainID}/projects/${projectID}`)
    .then((response) => {
      dispatch(receiveProject(response.data.project));
    })
    .catch((error) => {
      dispatch(requestProjectFailure(projectID));
      showLimesError(error);
    });
};

export const fetchProjectIfNeeded = ({domainID, projectID}) => function(dispatch, getState) {
  const state = getState();
  if (state.project.id == projectID) {
    if (state.project.isFetching || state.project.requestedAt) {
      return;
    }
  }
  return dispatch(fetchProject({domainID, projectID}));
};

////////////////////////////////////////////////////////////////////////////////
// sync project

const syncProjectFailure = (projectID) => ({
  type: constants.SYNC_PROJECT_FAILURE,
  projectID,
});

const syncProjectRequested = (projectID) => ({
  type: constants.SYNC_PROJECT_REQUESTED,
  projectID,
});

const syncProjectStarted = (projectID) => ({
  type: constants.SYNC_PROJECT_STARTED,
  projectID,
});

const syncProjectFinished = (projectID) => ({
  type: constants.SYNC_PROJECT_FINISHED,
  projectID,
});

export const syncProject = ({domainID, projectID}) => function(dispatch, getState) {
  dispatch(syncProjectRequested(projectID));
  ajaxHelper.post(`/v1/domains/${domainID}/projects/${projectID}/sync`)
    .then((response) => {
      dispatch(syncProjectStarted(projectID));
    })
    .catch((error) => {
      dispatch(syncProjectFailure(projectID));
      showLimesError(error);
    });
};

export const pollRunningSyncProject = ({domainID, projectID}) => function(dispatch, getState) {
  //check the scraped_at timestamps of all project services to see if the
  //running sync has completed
  ajaxHelper.get(`/v1/domains/${domainID}/projects/${projectID}`, { resource: 'none' })
    .catch((error) => {
      dispatch(syncProjectFailure(projectID));
      showLimesError(error);
    })
    .then((response) => {
      const oldServices = getState().project.services || {};
      const newServices = ((response.data.project || {}).services || []);
      let allUpdated = true; //until proven otherwise
      for (const srv of newServices) {
        const oldScrapedAt = (oldServices[srv.type] || {}).scraped_at || 0;
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
        dispatch(syncProjectFinished(projectID));
        dispatch(fetchProject({domainID, projectID}));
      }
    });
};
