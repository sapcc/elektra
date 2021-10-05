import React from "react";
import { BrowserRouter, Route, Redirect } from "react-router-dom";
import LoadbalancerList from "./loadbalancers/LoadbalancerList";
import Tabs from "./Tabs";
import NewLoadbalancer from "./loadbalancers/NewLoadbalancer";
import Details from "./loadbalancers/Details";
import NewL7Policy from "./l7policies/NewL7Policy";
import NewL7Rule from "./l7Rules/NewL7Rule";
import NewListener from "./listeners/NewListener";
import NewPool from "./pools/NewPool";
import NewMember from "./members/NewMember";
import NewHealthMonitor from "./healthmonitor/NewHealthMonitor";
import EditHealthMonitor from "./healthmonitor/EditHealthMonitor";
import HealthMonitorJSON from "./healthmonitor/HealthmonitorJSON";
import AttachFIP from "./loadbalancers/AttachFIP";
import LoadbalancerJSON from "./loadbalancers/LoadbalancerJSON";
import EditLoadbalancer from "./loadbalancers/EditLoadbalancer";
import EditListener from "./listeners/EditListener";
import ListenerJSON from "./listeners/ListenerJSON";
import EditPool from "./pools/EditPool";
import PoolJSON from "./pools/PoolJSON";
import EditMember from "./members/EditMember";
import MemberJSON from "./members/MemberJSON";
import EditL7Policy from "./l7policies/EditL7Policy";
import L7PolicyJSON from "./l7policies/L7PolicyJSON";
import EditL7Rule from "./l7Rules/EditL7Rule";
import L7RuleJSON from "./l7Rules/L7RuleJSON";

const Router = (props) => {
  const tabsConfig = [
    {
      to: "/loadbalancers",
      label: "Load Balancers",
      component: LoadbalancerList,
    },
    // { to: '/pools', label: 'Project Pools', component: SharedPoolList }
  ];

  return (
    <BrowserRouter basename={`${window.location.pathname}?r=`}>
      <div>
        <Route exact path="/" render={() => <Redirect to="/loadbalancers" />} />
        <Route
          path="/:activeTab"
          children={({ match, location, history }) =>
            React.createElement(
              Tabs,
              Object.assign({}, { match, location, history, tabsConfig }, props)
            )
          }
        />
        <Route exact path="/loadbalancers/new" component={NewLoadbalancer} />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/edit"
          component={EditLoadbalancer}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/show/edit"
          component={EditLoadbalancer}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/attach_fip"
          component={AttachFIP}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/show/attach_fip"
          component={AttachFIP}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/json"
          component={LoadbalancerJSON}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/show/json"
          component={LoadbalancerJSON}
        />
        <Route
          path={[
            "/loadbalancers/:loadbalancerID/show",
            "/loadbalancers/:loadbalancerID/l7policies",
            "/loadbalancers/:loadbalancerID/listeners",
            "/loadbalancers/:loadbalancerID/pools",
          ]}
          component={Details}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/new"
          component={NewListener}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/edit"
          component={EditListener}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/json"
          component={ListenerJSON}
        />

        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/new"
          component={NewPool}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/edit"
          component={EditPool}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/json"
          component={PoolJSON}
        />

        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/members/new"
          component={NewMember}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/members/:memberID/edit"
          component={EditMember}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/members/:memberID/json"
          component={MemberJSON}
        />

        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/healthmonitor/new"
          component={NewHealthMonitor}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/healthmonitor/:healthmonitorID/edit"
          component={EditHealthMonitor}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/pools/:poolID/healthmonitor/:healthmonitorID/json"
          component={HealthMonitorJSON}
        />

        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/l7policies/new"
          component={NewL7Policy}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/l7policies/:l7policyID/edit"
          component={EditL7Policy}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/l7policies/:l7policyID/json"
          component={L7PolicyJSON}
        />

        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/l7policies/:l7policyID/l7rules/new"
          component={NewL7Rule}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/l7policies/:l7policyID/l7rules/:l7ruleID/edit"
          component={EditL7Rule}
        />
        <Route
          exact
          path="/loadbalancers/:loadbalancerID/listeners/:listenerID/l7policies/:l7policyID/l7rules/:l7ruleID/json"
          component={L7RuleJSON}
        />
      </div>
    </BrowserRouter>
  );
};

export default Router;
