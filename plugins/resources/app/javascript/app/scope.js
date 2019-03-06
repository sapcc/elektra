/*
 * Most of the actions, reducers and components get reduced on multiple levels
 * (with the levels being one of "cluster", "domain" or "project"). Therefore,
 * they're written fairly generically and the variance between different levels
 * is encapsulated in the Scope class defined here. A Scope can be constructed
 * in one of three ways:
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
}
