import { combineReducers } from 'redux'
import * as search_reducers from './search/reducers';
// load role assignments reducers from identity plugin
import { role_assignments } from '../../../../identity/app/javascript/role_assignments/reducers';
import { network_usage_stats } from '../../../../networking/app/javascript/network_usage_stats/reducers';

const search = combineReducers(search_reducers)

export {
  search, role_assignments, network_usage_stats
}
