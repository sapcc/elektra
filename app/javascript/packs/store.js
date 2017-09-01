import { createStore, combineReducers, applyMiddleware, compose } from 'redux';
import ReduxThunk from 'redux-thunk';

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

const combineNestedReducers = (reducers) => {
   if (typeof reducers === 'Object'){
     var nestedReducers = {};
     for(let key of Object.keys(reducers) ) {
       nestedReducers[key] = combineNestedReducers(reducers[key]);
     }
     return combineReducers(nestedReducers);
   } else if (typeof reducers === 'function') {
     return combineReducers(reducers)
   }
};

const configureStore = (reducers) => (
  console.log('::::::::::::::.',combineNestedReducers(reducers))
  // createStore(combineNestedReducers(reducers), composeEnhancers(
  //   applyMiddleware(ReduxThunk)
  // ))
);

export default configureStore;
