/* eslint-disable no-undef */
import { DefeatableLink } from "lib/components/defeatable_link"
import { SearchField } from "lib/components/search_field"
import SecurityGroupItem from "./item"
import { pluginAjaxHelper } from "lib/ajax_helper"
const ajaxHelper = pluginAjaxHelper("networking")
import React from "react"

const List = ({ loadSecurityGroupsOnce, securityGroups, handleDelete }) => {
  const [searchTerm, setSearchTerm] = React.useState("")
  const { isFetching } = securityGroups

  const [cachedProjects, setCachedProjects] = React.useState()

  React.useEffect(() => {
    loadSecurityGroupsOnce()
  }, [])

  React.useEffect(() => {
    if (!securityGroups.items || securityGroups.items.length === 0) return

    const projectIDs = Object.keys(
      securityGroups.items.reduce((map, sg) => {
        map[sg.project_id] = true
        return map
      }, {})
    )

    ajaxHelper
      .get(`cache/objects-by-ids?ids=${projectIDs.join(",")}`)
      .then((response) => {
        const items = response.data
        const itemsById = items.reduce((map, i) => {
          map[i.id] = i
          return map
        }, {})
        setCachedProjects(itemsById)
      })
  }, [securityGroups.items])

  const filteredItems = React.useMemo(() => {
    let items = securityGroups.items || []

    if (searchTerm && searchTerm.replace(/\s/g, "").length > 0) {
      const regex = new RegExp(searchTerm.trim(), "i")

      items = items.filter(
        (i) => `${i.id} ${i.name} ${i.description} `.search(regex) >= 0
      )
    }
    return items
  }, [securityGroups, searchTerm])

  if (!policy.isAllowed("networking:security_group_list")) {
    return <span>You are not allowed to see this page</span>
  }

  return (
    <>
      <div className="toolbar">
        {securityGroups.items && securityGroups.items.length >= 10 && (
          <SearchField
            onChange={(term) => setSearchTerm(term)}
            placeholder="ID, name or description"
            text="Searches by ID, name or description in visible security group list only.
                    Entering a search term will automatically start loading the next pages
                    and filter the loaded items using the search term. Emptying the search
                    input field will show all currently loaded items."
          />
        )}
        <div style={{ paddingLeft: "10px" }}>
          Security Groups found:{filteredItems.length}
        </div>

        <div className="main-buttons">
          {policy.isAllowed("networking:security_group_create") &&
            (isFetching ? (
              <DefeatableLink to="/new" className="btn btn-primary" disabled>
                New Security Group
              </DefeatableLink>
            ) : (
              <DefeatableLink to="/new" className="btn btn-primary">
                New Security Group
              </DefeatableLink>
            ))}
        </div>
      </div>

      <table className="table shares">
        <thead>
          <tr>
            <th>Name / ID</th>
            <th>Description</th>
            <th>Owning Project</th>
            <th>Shared</th>
            <th className="snug"></th>
          </tr>
        </thead>
        <tbody>
          {filteredItems && filteredItems.length > 0 ? (
            filteredItems.map((securityGroup, index) => (
              <SecurityGroupItem
                key={index}
                project={
                  cachedProjects && cachedProjects[securityGroup.project_id]
                }
                securityGroup={securityGroup}
                handleDelete={handleDelete}
              />
            ))
          ) : (
            <tr>
              <td colSpan="4">
                {isFetching ? (
                  <span className="spinner" />
                ) : (
                  "No security groups found."
                )}
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {/*<AjaxPaginate
          hasNext={this.props.securityGroups.hasNext}
          isFetching={this.props.securityGroups.isFetching}
          onLoadNext={this.props.securityGroups.loadNext}/>
        */}
    </>
  )
}

export default List
