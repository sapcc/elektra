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

////////////////////////////////////////////////////////////////////////////////

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
      addError(React.createElement(ErrorsList, {
        errors: limesErrorMessage(error)
      }))
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
