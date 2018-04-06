/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import Ports from '../containers/ports/list'
import ShowPortModal from '../containers/ports/show';
import NewPortModal from '../containers/ports/new';

// render all components inside a hash router
export default (props) => {
  //console.log(props)
  return (
    <HashRouter /*hashType="noslash"*/ >
      <div>
        {/* redirect root to shares tab */}
        { policy.isAllowed("networking:port_list") &&
          <Route exact path="/" render={ () => <Redirect to="/ports"/>}/>
        }
        { policy.isAllowed("networking:port_list") &&
          <Route path="/ports" render={(routeProps) => <Ports {...routeProps} instancesPath={props.instancesPath}/>}/>
        }
        { policy.isAllowed("networking:port_create") &&
          <Route exact path="/ports/new" component={NewPortModal}/>
        }
        <Route exact path="/ports/:id/show" component={ShowPortModal}/>
      </div>
    </HashRouter>
  )
}
