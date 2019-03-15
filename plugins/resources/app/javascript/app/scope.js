import DomainResource from './components/domain/resource';
import ProjectResource from './components/project/resource';

/*
 * Most of the actions, reducers and components get reused on multiple levels
 * (with the levels being one of "cluster", "domain" or "project"). Therefore,
 * they're written fairly generically and the variance between different levels
 * is mostly encapsulated in the Scope class defined here. A Scope can be
 * constructed in one of three ways:
 *
 *     const projectScope = new Scope({ domainID, projectID });
 *     const domainScope  = new Scope({ domainID });
 *     const clusterScope = new Scope({});
 *
 * In practice, the constructor argument is passed down the React foodchain in
 * the field `props.scopeData`:
 *
 *     const currentScope = new Scope(props.scopeData);
 */
export class Scope {
  constructor(scopeData) {
    this.domainID = scopeData.domainID;
    this.projectID = scopeData.projectID;
  }

  level() {
    if (this.projectID) return 'project';
    if (this.domainID)  return 'domain';
    return 'cluster';
  }
  sublevel() {
    if (this.projectID) return null; //there is nothing below projects
    if (this.domainID)  return 'project';
    return 'domain';
  }
  isProject() {
    return this.projectID ? true : false;
  }
  isDomain() {
    return this.domainID && !this.projectID;
  }
  isCluster() {
    return !this.domainID;
  }

  urlPath() {
    if (this.projectID) return `/v1/domains/${this.domainID}/projects/${this.projectID}`;
    if (this.domainID)  return `/v1/domains/${this.domainID}`;
    return `/v1/clusters/${scopeData.clusterID}`;
  }
  subscopesUrlPath() {
    if (this.projectID) return null; //there is nothing below projects
    if (this.domainID)  return `/v1/domains/${this.domainID}/projects`;
    return `/v1/clusters/${scopeData.clusterID}/domains`;
  }

  descendIntoSubscope(id) {
    if (this.projectID) return null; //there is nothing below projects
    if (this.domainID) {
      return { clusterID: this.clusterID, domainID: this.domainID, projectID: id };
    }
    return { clusterID: this.clusterID, domainID: id };
  }

  //Level-specific component for resource bars inside a <Category/>.
  resourceComponent() {
    if (this.projectID) return ProjectResource;
    if (this.domainID)  return DomainResource;
    return null; //TODO ClusterResource
  }

  //Level-specific validations for quota values entered into <EditModal />.
  validateQuotaInput(newQuota, res) {
    if (this.projectID) {
      if (newQuota < res.usage) {
        return 'overspent';
      }
      return null;
    }
    else if (this.domainID) {
      if (newQuota < res.projects_quota) {
        return 'overspent';
      }
      return null;
    }
    else {
      return null; //there is no quota for clusters
    }
  }
  overspentMessage() {
    if (this.projectID) return 'Must be more than current usage.';
    if (this.domainID)  return 'Must be more than quota of projects.';
    return null; //there is no quota for clusters
  }
}
