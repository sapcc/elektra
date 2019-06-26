import * as constants from '../constants';
import { createAjaxHelper } from 'ajax_helper';
import { addNotice, addError } from 'lib/flashes';

var ajaxHelper = null;

export const configureCastellumAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts);
};

const fetchCastellumResourceConfig = (projectID) => (dispatch, getState) => {
  dispatch({
    type:        constants.REQUEST_CASTELLUM_RESOURCE_CONFIG,
    requestedAt: Date.now(),
  });

  return ajaxHelper.get(`/v1/projects/${projectID}/resources/nfs-shares`)
    .then(response => {
      dispatch({
        type:       constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG,
        data:       response.data,
        receivedAt: Date.now(),
      });
    })
    .catch(error => {
      //404 is not an error, it just shows that autoscaling is disabled on this
      //project resource
      if (error.response && error.response.status && error.response.status == 404) {
        dispatch({
          type:       constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG,
          data:       null,
          receivedAt: Date.now(),
        });
      } else {
        let msg = error.message;
        if (error.response && error.response.data) {
          msg = `${msg}: ${error.response.data}`;
        }
        dispatch({
          type:    constants.REQUEST_CASTELLUM_RESOURCE_CONFIG_FAILURE,
          message: msg,
        });
      }
    });
};

export const fetchCastellumResourceConfigIfNeeded = (projectID) => (dispatch, getState) => {
  const castellumState = getState().castellum || {};
  const { isFetching, requestedAt } = castellumState.resourceConfig || {};
  if (!isFetching && !requestedAt) {
    return dispatch(fetchCastellumResourceConfig(projectID));
  }
};
