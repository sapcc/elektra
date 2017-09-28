/* eslint no-console:0 */
import { connect } from 'react-redux';
import Container from './tabs/components/tabs_container';

import TabReducers from './tabs/reducers';
import ShareReducers from './shares/reducers';

const Reducers = Object.assign({}, TabReducers, ShareReducers);

export default { Reducers, Container};
