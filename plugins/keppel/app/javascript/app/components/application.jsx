import { HashRouter, Route } from 'react-router-dom';
import AccountList from '../containers/accounts/list';

export default (props) => {
  const { clusterId, canEdit, isAdmin } = props;
  const rootProps = { clusterID: clusterId, canEdit, isAdmin };

  return (
    <HashRouter>
      <div>
        <Route exact path="/" render={(props) => <AccountList {...rootProps} />} />
      </div>
    </HashRouter>
  );
};
