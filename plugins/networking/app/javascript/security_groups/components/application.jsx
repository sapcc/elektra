/* eslint no-console:0 */
import { HashRouter, Route, Switch } from "react-router-dom"

import SecurityGroups from "../containers/security_groups/list"
import NewSecurityGroupModal from "../containers/security_groups/new"
import EditSecurityGroupModal from "../containers/security_groups/edit"

import SecurityGroupRules from "../containers/security_group_rules/list"
import NewSecurityGroupRuleModal from "../containers/security_group_rules/new"
import RBACs from "../containers/security_groups/rbacs"

import Title from "./title"

// render all components inside a hash router
export default (props) => {
  //console.log(props)
  return (
    <HashRouter /*hashType="noslash"*/>
      <React.Fragment>
        <Title />
        <Switch>
          {policy.isAllowed("networking:rule_list") && (
            <Route
              path="/security-groups/:securityGroupId/rules"
              component={SecurityGroupRules}
            />
          )}
          {policy.isAllowed("networking:security_group_list") && (
            <Route path="/" component={SecurityGroups} />
          )}
        </Switch>

        {policy.isAllowed("networking:security_group_create") && (
          <Route exact path="/new" component={NewSecurityGroupModal} />
        )}
        {policy.isAllowed("networking:security_group_update") && (
          <Route exact path="/:id/edit" component={EditSecurityGroupModal} />
        )}

        {policy.isAllowed("networking:rule_create") && (
          <Route
            exact
            path="/security-groups/:securityGroupId/rules/new"
            component={NewSecurityGroupRuleModal}
          />
        )}

        <Route exact path="/:securityGroupId/rbacs" component={RBACs} />
      </React.Fragment>
    </HashRouter>
  )
}
