/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import ProjectOverview from '../containers/project/overview';
import ProjectEditModal from '../containers/project/edit';
import ProjectSettingsModal from '../containers/project/settings';

const routesForProjectLevel = (props) => {
  const { domainId, projectId, flavorData, docsUrl } = props;
  const rootProps = { domainID: domainId, projectID: projectId, flavorData };

  return (
    <HashRouter>
      <div>
        <Route path="/" render={(props) => <ProjectOverview {...rootProps} {...props} /> }/>

        { policy.isAllowed("project:edit") &&
          <Route exact path="/edit/:categoryName" render={(props) => <ProjectEditModal {...rootProps} {...props} /> }/>
        }
        { policy.isAllowed("project:edit") &&
          <Route exact path="/settings" render={(props) => <ProjectSettingsModal {...rootProps} {...props} docsUrl={docsUrl} /> }/>
        }
      </div>
    </HashRouter>
  )
}

const routesForDomainLevel = (props) => (<p>TODO: domain level</p>);
const routesForClusterLevel = (props) => (<p>TODO: cluster level</p>);

export default (props) => {
  return props.projectId ? routesForProjectLevel(props)
       : props.domainId  ? routesForDomainLevel(props)
       :                   routesForClusterLevel(props);
}
