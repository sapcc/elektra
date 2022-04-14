import { combineReducers } from "redux"
import * as search_reducers from "plugins/tools/app/javascript/widgets/universal_search/search/reducers"
import * as topology_reducers from "plugins/tools/app/javascript/widgets/universal_search/topology/reducers"

// load role assignments reducers from identity plugin
import { role_assignments } from "plugins/identity/app/javascript/widgets/role_assignments/reducers"
import { network_usage_stats } from "plugins/networking/app/javascript/widgets/network_usage_stats/reducers"

const search = combineReducers(search_reducers)
const topology = combineReducers(topology_reducers)

export { search, role_assignments, network_usage_stats, topology }
