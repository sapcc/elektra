import * as constants from '../constants';
import { createAjaxHelper } from 'ajax_helper';
import { addError } from 'lib/flashes';

let ajaxHelper = null;

const utilizationQuery = `max by (metric,share_id) (netapp_capacity_svm{metric=~"size_(?:used|reserved|total)(?:_by_snapshots)?"})`;

export const configureMaiaAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts);
};

const maiaErrorMessage = (error) =>
  error.response && error.response.data.error ||
  error.message

const fetchShareUtilization = () => (dispatch, getState) => {
  dispatch({ type: constants.REQUEST_SHARE_UTILIZATION });
  return ajaxHelper.get(`/query`, { params: { query: utilizationQuery } })
    .then(response => {
      //parse according to https://prometheus.io/docs/prometheus/latest/querying/api/
      if (typeof response.data != "object") {
        dispatch({ type: constants.REQUEST_SHARE_UTILIZATION_FAILURE });
        addError(`Could not load share utilization: ${error.response}`)
      }
      else if (response.data.status != "success") {
        dispatch({ type: constants.REQUEST_SHARE_UTILIZATION_FAILURE });
        addError(`Could not load share utilization: ${error.response.data.error}`)
      }
      else {
        dispatch({
          type: constants.RECEIVE_SHARE_UTILIZATION,
          data: response.data.data,
        });
      }
    })
    .catch(error => {
      dispatch({ type: constants.REQUEST_SHARE_UTILIZATION_FAILURE });
      addError(`Could not load share utilization: ${error.message}`)
    })
};

export const fetchShareUtilizationIfNeeded = () => (dispatch, getState) => {
  const u = getState().maia.utilization || {};
  if (u.data == null && !u.wasRequested) {
    dispatch(fetchShareUtilization());
  }
};
