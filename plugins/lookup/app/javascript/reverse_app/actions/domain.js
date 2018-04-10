import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### DOMAIN #########################
const requestDomain= json => (
  {
    type: constants.REQUEST_DOMAIN,
    requestedAt: Date.now()
  }
);

const receiveDomain= json => (
  {
    type: constants.RECEIVE_DOMAIN,
    data: json,
    receivedAt: Date.now()
  }
);

const requestDomainFailure= (err) => (
  {
    type: constants.REQUEST_DOMAIN_FAILURE,
    error: err
  }
);

const fetchDomain= (searchValue,projectId) =>
  function(dispatch,getSate) {
    dispatch(requestDomain());
    ajaxHelper.get(`/reverselookup/domain/${projectId}`).then( (response) => {
      const searchedValue = getSate().object.searchedValue
      if(searchValue!=searchedValue) return
      return dispatch(receiveDomain(response.data));
    })
    .catch( (error) => {
      dispatch(requestDomainFailure(`Could not load domain (${error.message})`));
    });
  }

export {
  fetchDomain
}
