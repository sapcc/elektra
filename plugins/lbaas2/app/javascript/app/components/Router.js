import React from 'react';
import { HashRouter, Route, Redirect } from 'react-router-dom'
import LoadbalancerList from './loadbalancers/LoadbalancerList';
import SharedPoolList from './pools/SharedPoolList'
import Tabs from './Tabs'
import NewLoadbalancer from './loadbalancers/NewLoadbalancer'
import Details from './loadbalancers/Details'
import NewL7Policy from './l7policies/NewL7Policy'
import NewL7Rule from './l7Rules/NewL7Rule'
import NewListener from './listeners/NewListener'
import NewPool from './pools/NewPool'

const Router = (props) => {

  const tabsConfig = [
    { to: '/loadbalancers', label: 'Load Balancers', component: LoadbalancerList },
    { to: '/pools', label: 'Project Pools', component: SharedPoolList }
  ]

  return ( 
    <HashRouter /*hashType="noslash"*/ >
      <div>
          <Route exact path="/" render={ () => <Redirect to="/loadbalancers"/>}/>
          <Route path="/:activeTab" children={ ({match, location, history}) =>
            React.createElement(Tabs, Object.assign({}, {match, location, history, tabsConfig}, props))
          }/>
          <Route exact path="/loadbalancers/new" component={NewLoadbalancer}/>
          <Route 
            path={["/loadbalancers/:loadbalancerID/show", "/loadbalancers/:loadbalancerID/l7policies", "/loadbalancers/:loadbalancerID/listeners", "/loadbalancers/:loadbalancerID/pools"]}
            component={Details}
          />
          <Route exact path="/loadbalancers/:loadbalancerID/listeners/new" component={NewListener}/>
          <Route exact path="/loadbalancers/:loadbalancerID/pools/new" component={NewPool}/>
          <Route exact path="/loadbalancers/:loadbalancerID/l7policies/new" component={NewL7Policy}/>
          <Route exact path="/loadbalancers/:loadbalancerID/l7policies/:l7policy/l7rules/new" component={NewL7Rule}/>
      </div>
    </HashRouter>
   );
}
 
export default Router;