/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom';
import { connect } from 'react-redux';
import * as Reducers from './reducers';


import Clusters from './containers/clusters/list';
import { configureKubernikusAjaxHelper } from './kubernikus_ajax_helper';



// render all components inside a hash router
const Container = (props) =>
  <HashRouter /*hashType="noslash"*/ >
    <div>
      { configureKubernikusAjaxHelper(props.kubernikusbaseurl, props.token) }
      { policy.isAllowed("kubernetes:application_list") &&
        <Route exact path="/" component={Clusters}/>
      }

    </div>
  </HashRouter>

export default { Reducers, Container };
