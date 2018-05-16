import { combineReducers } from 'redux'
import * as search_reducers from './search/reducers';
import * as role_assignments_reducers from './role_assignments/reducers';

// export const search = combineReducers(search_reducers)
const search = combineReducers(search_reducers)
const role_assignments = combineReducers(role_assignments_reducers)

export {
  search,
  role_assignments
}
