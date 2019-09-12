import { HashRouter, Route } from 'react-router-dom';

//TODO
const AccountList = (props) => <p>Hello World</p>;

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
