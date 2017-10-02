import { connect } from  'react-redux';
// import { Tabs, Tab } from 'react-bootstrap';
import { getCurrentTabFromUrl, setCurrentTabToUrl } from '../urlHelper'
import { selectTab } from '../actions'
import {
  BrowserRouter,
  Route,
  NavLink,
  HashRouter,
  withRouter
} from 'react-router-dom'

const Shares = (props) =>
  <div>Shares</div>

const Snapshots = (props) =>
  <div>Snapshots</div>

const ShareNetworks = (props) =>
  <div>Share Networks</div>

const Tabs = withRouter(({ match, location, history }) => {
  const listItems = [
    { to: '/shares', label: 'Shares' },
    { to: '/snapshots', label: 'Snapshots' },
    { to: '/share-networks', label: 'Share Networks' }
  ].map((tab) =>
    <li className={location.pathname==tab.to ? 'active' : ''} key={tab.to}>
      <NavLink to={tab.to} replace={true}>{tab.label}</NavLink>
    </li>
  );

  return <ul className="nav nav-tabs" role="tablist">
    { listItems }
  </ul>
})

const TabsContainer = (props) => {

  return <HashRouter>
    <div>
      <Tabs/>
      <div className="tab-content">
        <Route path="/shares" component={Shares}/>
        <Route path="/snapshots" component={Snapshots}/>
        <Route path="/share-networks" component={ShareNetworks}/>
      </div>
    </div>
  </HashRouter>
}

export default TabsContainer
