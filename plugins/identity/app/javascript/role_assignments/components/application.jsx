import { Tabs, Tab } from 'react-bootstrap';
import ProjectRoleAssignments from '../containers/project_role_assignments'

export default ({activeTab, projectId, domainId}) => {
  return(
    <Tabs defaultActiveKey={activeTab || 'userRoles'} id="item_payload">
      <Tab eventKey='userRoles' title="User Role Assignments">
        <ProjectRoleAssignments
          projectId={projectId}
          projectDomainId={domainId}
          type='user'
        />
      </Tab>
      <Tab eventKey='groupRoles' title="Group Role Assignments">
        <ProjectRoleAssignments
          projectId={projectId}
          projectDomainId={domainId}
          type='group'
        />
      </Tab>
    </Tabs>
  )
}
