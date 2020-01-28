import React from 'react';
import { HashRouter, Route, Redirect } from 'react-router-dom'
import LoadbalancerList from './loadbalancerList';

const Router = () => {

  return ( 
    <HashRouter /*hashType="noslash"*/ >
      <div>
          <Route exact path="/" component={LoadbalancerList}/>
      </div>
    </HashRouter>
   );
}
 
export default Router;