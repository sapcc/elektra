import * as constants from '../constants';
import { createAjaxHelper } from 'ajax_helper';
import { addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

let ajaxHelper = null;

export const configureCastellumAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts);
};

const castellumErrorMessage = (error) =>
  error.response && error.response.data ||
  error.message

const showCastellumError = (error) =>
  addError(React.createElement(ErrorsList, {
    errors: castellumErrorMessage(error)
  }))

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

export const deleteCastellumProjectResource = (projectID, assetType) => dispatch => (
  new Promise(resolve => {
    ajaxHelper.delete(`/v1/projects/${projectID}/resources/${assetType}`)
      .then(response => {
        dispatch({
          type:       constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG,
          projectID,
          assetType,
          data:       null,
          receivedAt: Date.now(),
        });
        resolve();
      })
      .catch(error => {
        //404 is not a problem
        const isNotFound = error.response && error.response.status == 404;
        if (!isNotFound) {
          showCastellumError(error);
        }
        resolve();
      });
  })
);

export const updateCastellumProjectResource = (projectID, assetType, config) => dispatch => (
  new Promise(resolve => {
    ajaxHelper.put(`/v1/projects/${projectID}/resources/${assetType}`, config)
      .then(response => {
        dispatch({
          type:       constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG,
          projectID,
          assetType,
          data:       config,
          receivedAt: Date.now(),
        });
        resolve();
      })
      .catch(error => {
        showCastellumError(error);
        resolve();
      });
  })
);
