import { withRouter, Link, Route, Redirect } from 'react-router-dom'
import ShareList from './shares/list'

const Snapshots = () => <div>Snapshots</div>
const ShareNetworks = () => <div>Share Networks</div>

const tabs = [
  { to: '/shares', label: 'Shares' },
  { to: '/snapshots', label: 'Snapshots' },
  { to: '/share-networks', label: 'Share Networks' }
]

const TabMenu = withRouter(({ match, location, history }) => {
  const tabItems =  tabs.map((tab) =>
    <li className={location.pathname.indexOf(tab.to)>-1 ? 'active' : ''} key={tab.to}>
      <Link to={tab.to} replace={true}>{tab.label}</Link>
    </li>
  )
  return <ul className="nav nav-tabs" role="tablist">{tabItems}</ul>
});

export default (props) => (
  <div>
    <TabMenu/>
    <div className="tab-content">
      <Route exact path="/" render={ () =>
        <Redirect to="/shares"/>
      }/>
    <Route path="/shares" component={() => <ShareList {...props}/>}/>
      <Route path="/snapshots" component={Snapshots}/>
      <Route path="/share-networks" component={ShareNetworks}/>
    </div>
  </div>
)
