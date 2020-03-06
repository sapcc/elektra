import React from 'react';
import { HashRouter, Route, Redirect } from 'react-router-dom'
import LoadbalancerList from './loadbalancers/LoadbalancerList';
import PoolList from './pools/PoolList'
import Tabs from './Tabs'
import NewLoadbalancer from './loadbalancers/NewLoadbalancer'
import Details from './loadbalancers/Details'

const Router = (props) => {

  const tabsConfig = [
    { to: '/loadbalancers', label: 'Load Balancers', component: LoadbalancerList },
    { to: '/pools', label: 'Pools', component: PoolList }
  ]

  return ( 
    <HashRouter /*hashType="noslash"*/ >
      <div>
          <Route exact path="/" render={ () => <Redirect to="/loadbalancers"/>}/>
          <Route path="/:activeTab" children={ ({match, location, history}) =>
            React.createElement(Tabs, Object.assign({}, {match, location, history, tabsConfig}, props))
          }/>
          <Route exact path="/loadbalancers/new" component={NewLoadbalancer}/>
          <Route exact path="/loadbalancers/:id/show" component={Details}/>
      </div>
    </HashRouter>
   );
}
 
export default Router;