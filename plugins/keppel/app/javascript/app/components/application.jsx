import { HashRouter, Route } from 'react-router-dom';
import AccountList from '../containers/accounts/list';
import AccountCreateModal from '../containers/accounts/create';
import RBACPoliciesEditModal from '../containers/rbac_policies/edit';

export default (props) => {
  const { clusterId, canEdit, isAdmin } = props;
  const rootProps = { clusterID: clusterId, canEdit, isAdmin };

  return (
    <HashRouter>
      <div>
        <Route path="/" render={(props) => <AccountList {...rootProps} />} />

        <Route exact path="/accounts/new" component={AccountCreateModal} />
        <Route exact path="/policies/:account" render={(props) => <RBACPoliciesEditModal {...props} {...rootProps} />} />
      </div>
    </HashRouter>
  );
};
