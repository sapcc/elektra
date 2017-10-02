import { connect } from  'react-redux';
import { Tabs, Tab } from 'react-bootstrap';
import { getCurrentTabFromUrl, setCurrentTabToUrl } from '../urlHelper'
import { selectTab } from '../actions'
import { Route, HashRouter, withRouter } from 'react-router-dom'

const Shares = (props) =>
  <div>Shares</div>

const Snapshots = (props) =>
  <div>Snapshots</div>

const ShareNetworks = (props) =>
  <div>Share Networks</div>

const TabsMenu = withRouter(({match, location, history}) =>
  <Tabs activeKey={location.pathname} onSelect={(uid) => {console.log(uid); history.push(uid)}} id="test">
    <Tab eventKey="/shares" title="Shares"><Shares/></Tab>
    <Tab eventKey="/snapshots" title="Snapshots">Snapshots content</Tab>
    <Tab eventKey="/share-networks" title="Share Networks">Share Networks content</Tab>
  </Tabs>
)

export default (props) => {
  return <HashRouter hashType="noslash">
    <div>
      <TabsMenu handleSelect={props.handleSelect}/>
    </div>
  </HashRouter>
}
