import { connect } from  'react-redux';
import { Tabs, Tab } from 'react-bootstrap';
import { getCurrentTabFromUrl, setCurrentTabToUrl } from '../urlHelper'
import { selectTab } from '../actions'
import {
  BrowserRouter as Router,
  Route,
  Link,
  HashRouter,
  StaticRouter
} from 'react-router-dom'

const TabsContainer = (props) => {
  return <HashRouter hashType="noslash">
    <div>
      <Tabs activeKey={props.activeTabUid} onSelect={props.handleSelect}>
        <Tab eventKey="shares" title="Shares">Shares Content</Tab>
        <Tab eventKey="snapshots" title="Snapshots">Snapshots content</Tab>
        <Tab eventKey="share-networks" title="Share Networks">Share Networks content</Tab>
      </Tabs>

      <ul>
        <li><Link to="/shares">Shares</Link></li>
        <li><Link to="/snapshots">Snapshots</Link></li>
        <li><Link to="/share-networks">Share Networks</Link></li>
      </ul>

      <Route path="/:uid" render={({match, location}) => {
        console.log('route',match,location)
        props.handleSelect(match.params.uid)
        return null
      }}/>
    </div>
  </HashRouter>
}



export default connect(
  state => ((pluginState) => ({
    /*activeTabUid: pluginState.activeTab.uid || getCurrentTabFromUrl() || 'shares'*/
    activeTabUid: pluginState.activeTab.uid || getCurrentTabFromUrl() || 'shares'
  }))(state.shared_filesystem_storage),

  dispatch => ({
    handleSelect: (uid) => {
      //setCurrentTabToUrl(uid)
      dispatch(selectTab(uid))
    }
  })
)(TabsContainer);
