import { combineReducers } from 'redux'
import * as role_assignments_reducers from './reducers/index';

const role_assignments = combineReducers(role_assignments_reducers)
export { role_assignments }
