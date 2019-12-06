import { HashRouter, Route, Redirect } from 'react-router-dom';
import AccountList from '../containers/accounts/list';
import AccountCreateModal from '../containers/accounts/create';
import RBACPoliciesEditModal from '../containers/rbac_policies/edit';

export default (props) => {
  const { projectId, canEdit, isAdmin } = props;
  const rootProps = { projectID: projectId, canEdit, isAdmin };

  return (
    <HashRouter>
      <div>
        {/* entry point */}
        <Route exact path="/" render={() => <Redirect to="/accounts" />} />

        {/* account list */}
        <Route path="/accounts" render={(props) => <AccountList {...rootProps} />} />

        {/* modal dialogs that are reached from /accounts */}
        {isAdmin && <Route exact path="/accounts/new" render={(props) => <AccountCreateModal {...props} {...rootProps} /> } />}
        <Route exact path="/accounts/:account/policies" render={(props) => <RBACPoliciesEditModal {...props} {...rootProps} />} />
      </div>
    </HashRouter>
  );
};
