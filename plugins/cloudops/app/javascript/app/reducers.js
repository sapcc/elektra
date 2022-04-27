import { combineReducers } from 'redux'
import * as search_reducers from '../../../../tools/app/javascript/universal_search/search/reducers';
import * as topology_reducers from '../../../../tools/app/javascript/universal_search/topology/reducers';

// load role assignments reducers from identity plugin
import { role_assignments } from '../../../../identity/app/javascript/role_assignments/reducers';
import { network_usage_stats } from '../../../../networking/app/javascript/network_usage_stats/reducers';

const search = combineReducers(search_reducers)
const topology = combineReducers(topology_reducers)

export {
  search, role_assignments, network_usage_stats, topology
}
