import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### USERS #########################
const requestUsers= json => (
  {
    type: constants.REQUEST_USERS,
    requestedAt: Date.now()
  }
);

const receiveUsers= json => (
  {
    type: constants.RECEIVE_USERS,
    data: json,
    receivedAt: Date.now()
  }
);

const requestUsersFailure= (err) => (
  {
    type: constants.REQUEST_USERS_FAILURE,
    error: err
  }
);

const fetchUsers= (projectId, searchBy) =>
  function(dispatch) {
    dispatch(requestUsers());
    ajaxHelper.get(`/reverselookup/users/${projectId}?filterby=${searchBy}`).then( (response) => {
      return dispatch(receiveUsers(response.data));
    })
    .catch( (error) => {
      dispatch(requestUsersFailure(`Could not load users (${error.message})`));
    });
  }

export {
  fetchUsers
}
