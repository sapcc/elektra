/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'
import { connect } from 'react-redux';
import * as Reducers from './reducers';

import Tabs from './components/tabs';
import ShareList from './containers/shares/list'
import EditShareModal from './containers/shares/edit';
import ShowShareModal from './containers/shares/show';
import NewShareModal from './containers/shares/new';
import AccessControlModal from './containers/shares/access_control';

import ShareNetworks from './containers/share_networks/list'

import Snapshots from './components/snapshots/list'

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

      <Route exact path="/shares/new" component={NewShareModal}/>
      <Route exact path="/shares/:id" component={ShowShareModal}/>
      <Route exact path="/shares/:id/edit" component={EditShareModal}/>
      <Route exact path="/shares/:id/access-control" component={AccessControlModal}/>
    </div>
  </HashRouter>

export default { Reducers, Container };
