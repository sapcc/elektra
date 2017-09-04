/* eslint no-console:0 */

import Reducers from './shares/reducers'
import { connect } from 'react-redux';

const Container = (props) => (
  <div>Shared Filesystem Storage</div>
)

export default { Reducers, Container};
