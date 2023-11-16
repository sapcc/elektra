import React from "react"

const RoleInfos = ({ items, isFetching, loadRoles }) => {
  React.useLayoutEffect(() => {
    loadRoles()
  }, [])

  if (isFetching)
    return (
      <span>
        <span className="spinner" />
        Loading...
      </span>
    )
  return (
    <table className="table">
      <thead>
        <tr>
          <th>Name</th>
          <th>ID</th>
        </tr>
      </thead>
      <tbody>
        {items
          .sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0))
          .map((item, i) => (
            <tr key={i}>
              <td>{item.name}</td>
              <td>{item.id}</td>
            </tr>
          ))}
      </tbody>
    </table>
  )
}

export default RoleInfos
