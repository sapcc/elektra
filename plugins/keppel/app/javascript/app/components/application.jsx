import { HashRouter, Route } from 'react-router-dom';
import AccountList from '../containers/accounts/list';
import AccountCreateModal from '../containers/accounts/create';
import RBACPoliciesEditModal from '../containers/rbac_policies/edit';

export default (props) => {
  const { projectId, canEdit, isAdmin } = props;
  const rootProps = { projectID: projectId, canEdit, isAdmin };

  return (
    <HashRouter>
      <div>
        <Route path="/" render={(props) => <AccountList {...rootProps} />} />

        {isAdmin && <Route exact path="/accounts/new" render={(props) => <AccountCreateModal {...props} {...rootProps} /> } />}
        <Route exact path="/policies/:account" render={(props) => <RBACPoliciesEditModal {...props} {...rootProps} />} />
      </div>
    </HashRouter>
  );
};
