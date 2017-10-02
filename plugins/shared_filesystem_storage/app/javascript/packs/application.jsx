/* eslint no-console:0 */
import { HashRouter } from 'react-router-dom'
import { connect } from 'react-redux';
import * as Reducers from './reducers';
import Tabs from './containers/tabs';

const Container = () =>
  <HashRouter /*hashType="noslash"*/ >
    <Tabs/>
  </HashRouter>

export default { Reducers, Container };
