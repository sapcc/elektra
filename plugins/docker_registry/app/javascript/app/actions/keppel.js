import { ajaxHelper } from 'ajax_helper';
import { addError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

import * as constants from '../constants';

const showError = (error) => (
  addError(React.createElement(ErrorsList, {
    errors: (error.response && error.response.data || error.message),
  }))
);

export const fetchAccounts = () => dispatch => {
  dispatch({
    type: constants.REQUEST_ACCOUNTS,
    requestedAt: Date.now(),
  });

  return ajaxHelper.get('/keppel/v1/accounts')
    .then(response => {
      dispatch({
        type: constants.RECEIVE_ACCOUNTS,
        data: response.data.accounts,
        receivedAt: Date.now(),
      });
    })
    .catch(error => {
      dispatch({ type: constants.REQUEST_ACCOUNTS_FAILURE });
      showError(error);
    });
};

export const fetchAccountsIfNeeded = () => (dispatch, getState) => {
  const state = getState().keppel.accounts;
  if (state.isFetching || state.requestedAt) {
    return;
  }
  return dispatch(fetchAccounts());
};
