import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const ajaxHelper = pluginAjaxHelper('networking')

//################### SUBNETS #########################
const requestSubnets= () =>
  ({
    type: constants.REQUEST_SUBNETS,
    requestedAt: Date.now()
  })
;

const requestSubnetsFailure= () => ({type: constants.REQUEST_SUBNETS_FAILURE});

const receiveSubnets= (json) =>
  ({
    type: constants.RECEIVE_SUBNETS,
    subnets: json,
    receivedAt: Date.now()
  })
;

const fetchSubnets= (page=null) =>
  function(dispatch,getState) {
    dispatch(requestSubnets());

    return ajaxHelper.get('/ports/subnets').then( (response) => {
      if (!response.data.errors) {
        dispatch(receiveSubnets(response.data.subnets));
      }
    })
    .catch( (error) => {
      dispatch(requestSubnetsFailure());
    });
  }
;

const shouldFetchSubnets= function(state) {
  if (state.subnets.isFetching || state.subnets.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchSubnetsIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchSubnets(getState())) { return dispatch(fetchSubnets()); }
  }
;

export {
  fetchSubnetsIfNeeded
}
