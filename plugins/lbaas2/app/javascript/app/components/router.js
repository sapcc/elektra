import React from 'react';
import { HashRouter, Route, Redirect } from 'react-router-dom'
import LoadbalancerList from './LoadbalancerList';
import ListenerList from './ListenerList';
import PoolList from './PoolList'
import Tabs from './Tabs'

const Router = (props) => {

  const tabsConfig = [
    { to: '/loadbalancers', label: 'Loadbalancers', component: LoadbalancerList },
    { to: '/pools', label: 'Pools', component: PoolList }
  ]

  return ( 
    <HashRouter /*hashType="noslash"*/ >
      <div>
          <Route exact path="/" render={ () => <Redirect to="/loadbalancers"/>}/>
          <Route path="/:activeTab" children={ ({match, location, history}) =>
            React.createElement(Tabs, Object.assign({}, {match, location, history, tabsConfig}, props))
          }/>
      </div>
    </HashRouter>
   );
}
 
export default Router;