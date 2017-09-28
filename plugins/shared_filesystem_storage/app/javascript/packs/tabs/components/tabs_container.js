import { connect } from  'react-redux';
import { Tabs, Tab } from 'react-bootstrap';
import { getCurrentTabFromUrl } from '../urlHelper'

console.log(getCurrentTabFromUrl);

const TabsContainer = (props) =>
  <Tabs activeKey={props.activeTabUid || "1"} onSelect={props.handleSelect} id="controlled-tab-example">
    <Tab eventKey="shares" title="Shares">Shares Content</Tab>
    <Tab eventKey="snapshots" title="Snapshots">Snapshots content</Tab>
    <Tab eventKey="share-networks" title="Share Networks">Share Networks content</Tab>
  </Tabs>

export default connect(
  state => ({
    activeTabUid: getCurrentTabFromUrl()
  }),
  despatch => ({
    handleSelect: () => console.log('select')
  })
)(TabsContainer);
