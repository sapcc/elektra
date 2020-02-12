import React from 'react';
import { HashRouter, Route } from 'react-router-dom'
import LoadbalancerList from './LoadbalancerList';

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