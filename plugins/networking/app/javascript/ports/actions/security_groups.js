import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const ajaxHelper = pluginAjaxHelper('networking')

//################### NETWORKS #########################
const requestSecurityGroups= () =>
  ({
    type: constants.REQUEST_SECURITY_GROUPS,
    requestedAt: Date.now()
  })
;

const requestSecurityGroupsFailure= () => ({type: constants.REQUEST_SECURITY_GROUPS_FAILURE});

const receiveSecurityGroups= (json) =>
  ({
    type: constants.RECEIVE_SECURITY_GROUPS,
    securityGroups: json,
    receivedAt: Date.now()
  })
;

const fetcSecurityGroups= () =>
  function(dispatch,getState) {
    dispatch(requestSecurityGroups());

    return ajaxHelper.get('/ports/security_groups').then( (response) => {
      if (response.data.errors) {
        dispatch(requestSecurityGroupsFailure())
      } else {
        dispatch(receiveSecurityGroups(response.data.security_groups));
      }
    })
    .catch( (error) => {
      dispatch(requestSecurityGroupsFailure());
    });
  }
;

const shouldFetchSecurityGroups= function(state) {
  if (state.securityGroups.isFetching || state.securityGroups.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchSecurityGroupsIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchSecurityGroups(getState())) { return dispatch(fetcSecurityGroups()); }
  }
;

export {
  fetchSecurityGroupsIfNeeded
}
