export default (item) => {
  if(!item) return null
  const scope = item.payload.scope || {}
  const isProject = item.cached_object_type=='project'
  let projectLink = null
  if(isProject) {
    projectLink = `/${item.domain_id}/${item.id}/home`
  } else if(scope.domain_id && scope.project_id) {
    projectLink = `/${scope.domain_id}/${scope.project_id}/home`
  }
  return projectLink
}
