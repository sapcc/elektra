import { createStore, combineReducers, applyMiddleware, compose } from 'redux';
import ReduxThunk from 'redux-thunk';
import { mergeDeep } from 'tools/deep_merge';
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

// combines all reducers and also nested reducers
const combineNestedReducers = (reducers) => {
  var nestedReducers = {};

  for(let key of Object.keys(reducers) ) {
    const values = reducers[key];

    if (typeof values === 'object'){
      // recursion
      nestedReducers[key] = combineNestedReducers(values);
    } else if (typeof values === 'function') {
      nestedReducers[key] = values
    }
  }
  return combineReducers(nestedReducers);
};

let storeReducers = {};
let store;

// creates an redux store with all combined reducers
export function configureStore(reducers) {
  // remember initial reducers
  storeReducers = mergeDeep(storeReducers,reducers);

  if(store) {
    store.replaceReducer(combineNestedReducers(storeReducers));
  } else {
    store = createStore(combineNestedReducers(reducers), composeEnhancers(
      applyMiddleware(ReduxThunk)
    ));
  }
  return store;
};

export function replaceOrAddReducers(reducers) {
  configureStore(reducers)
}
