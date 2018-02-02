/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'
import { connect } from 'react-redux';
import * as Reducers from './reducers';


import Clusters from './containers/clusters/list'

// render all components inside a hash router
const Container = (props) =>
  <HashRouter /*hashType="noslash"*/ >
    <div>

      { policy.isAllowed("kubernetes:application_list") &&
        <Route exact path="/" component={Clusters}/>
      }

    </div>
  </HashRouter>

export default { Reducers, Container };
