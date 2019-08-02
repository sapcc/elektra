import * as constants from '../constants';
import { createAjaxHelper } from 'ajax_helper';

let ajaxHelper = null;

export const configureCastellumAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts);
};

const castellumErrorMessage = (error) =>
  error.response && error.response.data ||
  error.message

export const fetchCastellumProjectConfig = (projectID) => (dispatch, getState) => {
  dispatch({
    type:        constants.REQUEST_CASTELLUM_CONFIG,
    projectID,
    requestedAt: Date.now(),
  });

  return ajaxHelper.get(`/v1/projects/${projectID}`)
    .then(response => {
      dispatch({
        type:       constants.RECEIVE_CASTELLUM_CONFIG,
        projectID,
        data:       response.data.resources,
        receivedAt: Date.now(),
      });
    })
    .catch(error => {
      let msg = error.message;
      if (error.response && error.response.data) {
        msg = `${msg}: ${error.response.data}`;
      }
      dispatch({
        type:      constants.REQUEST_CASTELLUM_CONFIG_FAILURE,
        projectID,
        message:   msg,
      });
    });
};
