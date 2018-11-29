import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const errorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message

// #################### Availability Zones ################
const requestServers= () => (
  {
    type: constants.REQUEST_SERVERS,
    requestedAt: Date.now()
  }
)

const requestServersFailure= (error) => (
  {
    type: constants.REQUEST_SERVERS_FAILURE,
    error
  }
);

const receiveServers= (items,hasNext) =>
  ({
    type: constants.RECEIVE_SERVERS,
    items,
    hasNext
  })
;

const fetchNextServers= () =>
  (dispatch,getState) => {
    const servers = getState()['servers']
    if(servers && servers.hasNext==false) return;

    const itemsCount = servers && servers.items && servers.items.length || 0
    const perPage = servers && servers.perPage || 100
    let page = Math.floor(itemsCount/perPage)
    const params = { type: 'server', page: page+1, per_page: perPage, enforce_scope: true }

    dispatch(requestServers());

    ajaxHelper.get(`/cache`, {params}).then( (response) => {
      if(response.data) {
        dispatch(receiveServers(response.data.items.map(s => s.payload), response.data.has_next))
      }
    }).catch(error => dispatch(requestServersFailure(errorMessage(error))))
  }
;

export {
  fetchNextServers
}
