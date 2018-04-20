import { combineReducers } from 'redux'
import * as search_reducers from './search/reducers';

export const search = combineReducers(search_reducers)
