/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import Loader from '../containers/loader';
import Overview from '../containers/overview';
import DetailsModal from '../containers/details/modal';
import EditModal from '../containers/edit';
import ProjectSettingsModal from '../containers/project/settings';

const routesForProjectLevel = (props) => {
  const { clusterId, domainId, projectId, flavorData, docsUrl, canEdit } = props;
  const scopeData = { clusterID: clusterId, domainID: domainId, projectID: projectId };
  const rootProps = { flavorData, scopeData };

  return <Loader scopeData={scopeData}>
    <HashRouter>
      <div>
        <Route path="/" render={(props) => <Overview {...rootProps} {...props} canEdit={canEdit} /> }/>

        { canEdit &&
          <Route exact path="/edit/:categoryName" render={(props) => <EditModal {...rootProps} {...props} /> }/>
        }
        { canEdit &&
          <Route exact path="/settings" render={(props) => <ProjectSettingsModal {...rootProps} {...props} docsUrl={docsUrl} /> }/>
        }
      </div>
    </HashRouter>
  </Loader>;
}

const routesForDomainLevel = (props) => {
  const { clusterId, domainId, flavorData, docsUrl, canEdit } = props;
  const scopeData = { clusterID: clusterId, domainID: domainId };
  const rootProps = { flavorData, scopeData };

  return <Loader scopeData={scopeData}>
    <HashRouter>
      <div>
        <Route path="/" render={(props) => <Overview {...rootProps} {...props} canEdit={canEdit} /> }/>

        <Route exact path="/details/:categoryName/:resourceName" render={(props) => <DetailsModal {...rootProps} {...props} /> }/>
        { canEdit &&
          <Route exact path="/edit/:categoryName" render={(props) => <EditModal {...rootProps} {...props} /> }/>
        }
      </div>
    </HashRouter>
  </Loader>;
}

const routesForClusterLevel = (props) => (<p>TODO: cluster level</p>);

export default (props) => {
  return props.projectId ? routesForProjectLevel(props)
       : props.domainId  ? routesForDomainLevel(props)
       :                   routesForClusterLevel(props);
}
