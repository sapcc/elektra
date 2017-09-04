import { createStore, combineReducers, applyMiddleware, compose } from 'redux';
import ReduxThunk from 'redux-thunk';

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

// creates an redux store with all combined reducers
const configureStore = (reducers) => (
  createStore(combineNestedReducers(reducers), composeEnhancers(
    applyMiddleware(ReduxThunk)
  ))
);

export { configureStore };
