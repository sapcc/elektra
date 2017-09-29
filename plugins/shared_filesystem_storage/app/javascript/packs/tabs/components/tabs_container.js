import { connect } from  'react-redux';
import { Tabs, Tab } from 'react-bootstrap';
import { getCurrentTabFromUrl, setCurrentTabToUrl } from '../urlHelper'
import { selectTab } from '../actions'
import {
  BrowserRouter,
  Route,
  NavLink,
  HashRouter
} from 'react-router-dom'

const Shares = (props) =>
  <div>Shares</div>

const Snapshots = (props) =>
  <div>Snapshots</div>

const ShareNetworks = (props) =>
  <div>Share Networks</div>

const TabsContainer = (props) => {
  console.log(props)
  return <HashRouter>
    <div>
      <ul className="nav nav-tabs" id="myTab" role="tablist">
        <li className="">
          <NavLink className="active" to="shares" replace={true}>Shares</NavLink>
        </li>
        <li className="nav-item">
          <NavLink to="snapshots" replace={true}>Snapshots</NavLink>
        </li>
        <li className="nav-item">
          <NavLink to="/share-networks" replace={true}>Share Networks</NavLink>
        </li>
      </ul>

      <div className="tab-content">
        <div className="tab-pane active" role="tabpanel">
          <Route path="/shares" component={Shares}/>
          <Route path="/snapshots" component={Snapshots}/>
          <Route path="/share-networks" component={ShareNetworks}/>
        </div>
      </div>
    </div>
  </HashRouter>
}

export default TabsContainer
