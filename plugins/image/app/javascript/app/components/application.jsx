/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import Tabs from './tabs';

import AvailableImages from '../containers/os_images/list_available'
import SuggestedImages from '../containers/os_images/list_suggested'
import ShowImageModal from '../containers/os_images/show';
import ImageMembersModal from '../containers/os_images/image_members';

let NewImageModal =() => <div>Test</div>

const tabsConfig = [
  { to: '/os-images/available', label: 'Available', component: AvailableImages },
  { to: '/os-images/suggested', label: 'Suggested', component: SuggestedImages }
]

// render all components inside a hash router
export default (props) => {
  //console.log(props)
  return (
    <HashRouter /*hashType="noslash"*/ >
      <div>
        {/* redirect root to os_images tab */}
        { policy.isAllowed("image:image_list") &&
          <Route exact path="/" render={ () => <Redirect to="/os-images/available"/>}/>
        }
        <Route path="/os-images/:activeTab" children={ ({match, location, history}) =>
          React.createElement(Tabs, Object.assign({}, {match, location, history, tabsConfig}, props))
        }/>

        { policy.isAllowed("image:image_get") &&
          <Route exact path="/os-images/:activeTab/:id/show" component={ShowImageModal}/>
        }
        { policy.isAllowed("image:image_get") &&
          <Route exact path="/os-images/:activeTab/:id/members" component={ImageMembersModal}/>
        }
      </div>
    </HashRouter>
  )
}
