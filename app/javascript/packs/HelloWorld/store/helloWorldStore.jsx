import { createStore, applyMiddleware, compose } from 'redux';
import helloWorldReducer from '../reducers/helloWorldReducer';
import ReduxThunk from 'redux-thunk';

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
const configureStore = (railsProps) => (
  createStore(helloWorldReducer, railsProps, composeEnhancers(
    applyMiddleware(ReduxThunk)
  ))
);

export default configureStore;
