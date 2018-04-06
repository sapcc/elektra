import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### PARENTS #########################
const requestParents= json => (
  {
    type: constants.REQUEST_PARENTS,
    requestedAt: Date.now()
  }
);

const receiveParents= json => (
  {
    type: constants.RECEIVE_PARENTS,
    data: json,
    receivedAt: Date.now()
  }
);

const requestParentsFailure= (err) => (
  {
    type: constants.REQUEST_PARENTS_FAILURE,
    error: err
  }
);

const fetchParents= (searchValue, projectId) =>
  function(dispatch, getSate) {
    dispatch(requestParents());
    ajaxHelper.get(`/reverselookup/parents/${projectId}`).then( (response) => {
      const searchedValue = getSate().project.searchedValue
      if(searchValue!=searchedValue) return
      return dispatch(receiveParents(response.data));
    })
    .catch( (error) => {
      dispatch(requestParentsFailure(`Could not load parents (${error.message})`));
    });
  }

export {
  fetchParents
}
