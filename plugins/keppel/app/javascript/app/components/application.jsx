import { HashRouter, Route, Redirect } from 'react-router-dom';
import Loader from '../containers/loader';
import AccountList from '../containers/accounts/list';
import AccountCreateModal from '../containers/accounts/create';
import RBACPoliciesEditModal from '../containers/rbac_policies/edit';
import RepositoryList from '../containers/repositories/list';
import ImageList from '../containers/images/list';

export default (props) => {
  const { projectId, canEdit, isAdmin, dockerInfo } = props;
  const rootProps = { projectID: projectId, canEdit, isAdmin, dockerInfo };

  return (
    <Loader>
      <HashRouter>
        <div>
          {/* entry point */}
          <Route exact path="/" render={() => <Redirect to="/accounts" />} />

          {/* account list */}
          <Route path="/accounts" render={(props) => <AccountList {...rootProps} />} />
          {/* modal dialogs that are reached from /accounts */}
          {isAdmin && <Route exact path="/accounts/new" render={(props) => <AccountCreateModal {...props} {...rootProps} /> } />}
          <Route exact path="/accounts/:account/policies" render={(props) => <RBACPoliciesEditModal {...props} {...rootProps} />} />

          {/* repository list within account */}
          <Route path="/account/:account" render={(props) => <RepositoryList {...props} {...rootProps} />} />

          {/* manifest list within repository */}
          <Route path="/repo/:account/:repo+" render={(props) => <ImageList {...props} {...rootProps} />} />
        </div>
      </HashRouter>
    </Loader>
  );
};
