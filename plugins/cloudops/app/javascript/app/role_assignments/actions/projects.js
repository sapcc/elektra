import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice as showNotice, addError as showError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

//################### OBJECTS #########################
const requestProjects= () => (
  {
    type: constants.REQUEST_PROJECTS,
    requestedAt: Date.now()
  }
);

const requestProjectsFailure= () => (
  {
    type: constants.REQUEST_PROJECTS_FAILURE
  }
);

const receiveProjects= ({projects,currentPage,hasNext,total}) => (
  {
    type: constants.RECEIVE_PROJECTS,
    receivedAt: Date.now(),
    projects,
    currentPage,
    hasNext,
    total
  }
);

const fetchProjects = (options) => {
  const params = {
    page: options.page || 1,
    domain: options.domain,
    project: options.project
  }
  return ajaxHelper.get('/search/projects', {params: params})
}

const searchProjects= ({domain,project}) =>
  function(dispatch) {
    dispatch(requestProjects());
    fetchProjects({domain,project}).then( (response) => {
      return dispatch(receiveProjects({
        projects: response.data.projects,
        currentPage: 1,
        total: response.data.total,
        hasNext: response.data.hasNext
      }));
    })
    .catch( (error) => {
      dispatch(requestProjectsFailure());
      showError(`Could not load projects (${error.message})`)
    });
  }

const loadNextProjects= ({domain,project}) =>
  function(dispatch, getState) {
    const {projects} = getState()['role_assignments'];
    const page = projects.currentPage + 1

    if(!projects.isFetching && projects.hasNext) {
      dispatch(requestProjects());
      fetchObjects({domain,project,page}).then( (response) => {
        return dispatch(receiveProjects({
          projects: response.data.projects,
          currentPage: page,
          total: response.data.total,
          hasNext: response.data.hasNext
        }));
      })
      .catch( (error) => {
        dispatch(requestProjectsFailure());
        showError(`Could not load projects (${error.message})`)
      });
    }
  }
;

export {
  searchProjects,
  loadNextProjects
}
