/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import * as constants from "../constants";
import { ajaxHelper } from "./ajax_helper";

// -------------- KUBERNIKUS INFO ---------------
const requestInfo = () => ({ type: constants.REQUEST_INFO });

const requestInfoFailure = error => ({
  type: constants.REQUEST_INFO_FAILURE,
  error
});

const receiveInfo = data => ({
  type: constants.RECEIVE_INFO,
  info: data
});

const setClusterFormDefaultVersion = data => ({
  type: constants.SET_CLUSTER_FORM_DEFAULT_VERSION,
  info: data
});

var loadInfo = options => function (dispatch, getState) {

  const { info } = getState();
  if (info != null && info.error === "") {
    return;
  } // don't fetch if we already have the Info

  dispatch(requestInfo());

  return ajaxHelper.get("/info", {
    contentType: 'application/json',
    success(data, textStatus, jqXHR) {
      dispatch(receiveInfo(data));
      if (options.workflow === 'new') {
        return dispatch(setClusterFormDefaultVersion(data));
      }
    },
    error(jqXHR, textStatus, errorThrown) {
      const errorMessage = typeof jqXHR.responseJSON === 'object' ? jqXHR.responseJSON.message : jqXHR.responseText;
      dispatch(requestInfoFailure(errorMessage));
      // retry up to 20 times
      if (getState().info.errorCount <= 20) {
        return dispatch(loadInfo(options));
      }
    }
  });
};

// export
export { loadInfo };