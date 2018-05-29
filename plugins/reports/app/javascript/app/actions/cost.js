import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### COST REPORT #########################

const requestCostReport= () => (
  {
    type: constants.REQUEST_COST_REPORT,
    requestedAt: Date.now()
  }
);

const receiveCostReport= json => (
  {
    type: constants.RECEIVE_COST_REPORT,
    data: json,
    receivedAt: Date.now()
  }
);

const requestCostReportFailure= (err) => (
  {
    type: constants.REQUEST_COST_REPORT_FAILURE,
    error: err
  }
);

const fetchCostReport= (value) => (
  (dispatch,getState) =>
    new Promise((handleSuccess,handleErrors) => {
      dispatch(requestCostReport())
      ajaxHelper.get(`/`).then((response) => {
        if (response.data.errors) {
          dispatch(requestCostReportFailure(`Could not load report (${response.data.errors})`))
        }else {
          dispatch(receiveCostReport(response.data))
          handleSuccess()
        }
      }).catch(error => {
        dispatch(requestCostReportFailure(`Could not load report (${error.message})`))
      })
    })
);

export {
  fetchCostReport
}
