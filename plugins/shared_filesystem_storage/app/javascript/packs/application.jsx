/* eslint no-console:0 */
import { HashRouter } from 'react-router-dom'
import { connect } from 'react-redux';
import * as Reducers from './reducers';
import Tabs from './containers/tabs';

const Container = (props) =>
  <HashRouter /*hashType="noslash"*/ >
    <Tabs {...props}/>
  </HashRouter>

export default { Reducers, Container };
