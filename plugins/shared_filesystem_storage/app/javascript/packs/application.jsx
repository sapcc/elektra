/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'
import { connect } from 'react-redux';
import * as Reducers from './reducers';

import Tabs from './containers/tabs';
import ShareList from './containers/shares/list'
import Snapshots from './components/snapshots/list'
import ShareNetworks from './components/share_networks/list'

const tabsConfig = [
  { to: '/shares', label: 'Shares', component: ShareList },
  { to: '/snapshots', label: 'Snapshots', component: Snapshots },
  { to: '/share-networks', label: 'Share Networks', component: ShareNetworks }
]

// render all components inside a hash router
const Container = (props) =>
  <HashRouter /*hashType="noslash"*/ >
    <div>
      {/* redirect root to shares tab */}
      <Route exact path="/" render={ () => <Redirect to="/shares"/>}/>
      <Route path="/:activeTab" children={ ({match, location, history}) =>
        React.createElement(Tabs, Object.assign({}, {match, location, history, tabsConfig}, props))
      }/>
    </div>
  </HashRouter>

export default { Reducers, Container };
