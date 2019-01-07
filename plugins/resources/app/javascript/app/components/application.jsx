/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from 'react-router-dom'

import ProjectOverview from '../containers/project/overview';

// render all components inside a hash router
export default (props) => {
  const { scopedDomainId, scopedProjectId } = props
  return (
    <HashRouter /*hashType="noslash"*/ >
      <div>
        <Route exact path="/" render={ () => <Redirect to="/project"/> }/>

        {/* routes for project level */}
        <Route exact path="/project" render={(props) =>
          <ProjectOverview domainID={scopedDomainId} projectID={scopedProjectId} {...props}/>
        }/>
        <Route exact path="/project/:domain_id/:project_id" render={(props) =>
          <ProjectOverview domainID={props.match.params.domain_id} projectID={props.match.params.project_id} {...props}/>
        }/>
      </div>
    </HashRouter>
  )
}
