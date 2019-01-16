/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import ProjectOverview from '../containers/project/overview';

const routesForProjectLevel = (props) => {
  const { domainId, projectId, flavorData } = props;
  return (
    <HashRouter>
      <div>
        <Route exact path="/" render={(props) =>
          <ProjectOverview domainID={domainId} projectID={projectId} flavorData={flavorData} {...props} />
        }/>
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
