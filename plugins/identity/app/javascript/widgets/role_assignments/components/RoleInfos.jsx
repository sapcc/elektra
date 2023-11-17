import React from "react"
import { SearchField } from "lib/components/search_field"

const ROLE_CSS_CLASSES = {
  admin: "warning",
  webmaster: "warning",
  member: "info",
  viewer: "info",
}
const sortRoles = (a, b) => {
  return (
    a.service.localeCompare(b.service) ||
    a.accessLevel.localeCompare(b.accessLevel)
  )
  //return a.service < b.service ? -1 : a.service > b.service ? 1 : 0
}

const RoleInfos = ({ items, isFetching, loadRoles }) => {
  const [searchTerm, setSearchTerm] = React.useState()

  React.useEffect(() => {
    loadRoles()
  }, [])

  const filteredItems = React.useMemo(
    () =>
      items
        .filter((item) => {
          if (!searchTerm) return true
          return (
            item.service.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.accessLevel.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.id.toLowerCase().includes(searchTerm.toLowerCase())
          )
        })
        .sort(sortRoles),
    [items, searchTerm]
  )

  if (isFetching)
    return (
      <span>
        <span className="spinner" />
        Loading...
      </span>
    )
  return (
    <>
      <div className="toolbar">
        <SearchField
          onChange={(term) => setSearchTerm(term)}
          placeholder={`Search...`}
          isFetching={isFetching}
          searchIcon={true}
          text="Search by name, ID, service or access level. It will find exact or partial matches."
        />
      </div>

      <table className="table">
        <thead>
          <tr>
            <th>Name</th>
            <th>ID</th>
            <th>Service</th>
            <th>Access Level</th>
          </tr>
        </thead>
        <tbody>
          {filteredItems.map((item, i) => (
            <tr key={i}>
              <td>{item.name}</td>
              <td>{item.id}</td>
              <td>{item.service}</td>
              <td>
                <span
                  className={`label label-${
                    ROLE_CSS_CLASSES[item.accessLevel] || "info"
                  }`}
                >
                  {item.accessLevel}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  )
}

export default RoleInfos
