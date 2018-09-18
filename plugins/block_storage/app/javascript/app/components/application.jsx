/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import Tabs from './tabs';

import Volumes from '../containers/volumes/list'
import Snapshots from '../containers/snapshots/list'
import ShowVolumeModal from '../containers/volumes/show'
import ShowSnapshotModal from '../containers/snapshots/show'

const tabsConfig = [
  { to: '/volumes', label: 'Volumes', component: Volumes },
  { to: '/snapshots', label: 'Volume Snapshots', component: Snapshots }
]

// render all components inside a hash router
export default (props) => {
  //console.log(props)
  return (
    <HashRouter /*hashType="noslash"*/ >
      <div>
        {/* redirect root to os_images tab */}
        { policy.isAllowed("block_storage:volume_list") &&
          <Route exact path="/" render={ () => <Redirect to="/volumes"/>}/>
        }
        <Route path="/:activeTab" children={ ({match, location, history}) =>
          React.createElement(Tabs, Object.assign({}, {match, location, history, tabsConfig}, props))
        }/>

        { policy.isAllowed("block_storage:volume_get") &&
          <React.Fragment>
            <Route exact path="/volumes/:id/show" component={ShowVolumeModal}/>
            <Route exact path="/snapshots/volumes/:id/show" component={ShowVolumeModal}/>
          </React.Fragment>
        }
        { policy.isAllowed("block_storage:snapshot_get") &&
          <Route exact path="/snapshots/:id/show" component={ShowSnapshotModal}/>
        }
      </div>
    </HashRouter>
  )
}
