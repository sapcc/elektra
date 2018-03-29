import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### GROUPS #########################
const requestGroups= json => (
  {
    type: constants.REQUEST_GROUPS,
    requestedAt: Date.now()
  }
);

const receiveGroups= json => (
  {
    type: constants.RECEIVE_GROUPS,
    data: json,
    receivedAt: Date.now()
  }
);

const requestGroupsFailure= (err) => (
  {
    type: constants.REQUEST_GROUPS_FAILURE,
    error: err
  }
);

const fetchGroups= (projectId, searchBy) =>
  function(dispatch) {
    dispatch(requestGroups());
    ajaxHelper.get(`/reverselookup/groups/${projectId}?filterby=${searchBy}`).then( (response) => {
      return dispatch(receiveGroups(response.data));
    })
    .catch( (error) => {
      dispatch(requestGroupsFailure(`Could not load groups (${error.message})`));
    });
  }

export {
  fetchGroups
}
