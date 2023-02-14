import React from "react"

const Users = (props) => (
  <ul className="plain-list plain-list-widespaced">
    {Object.keys(props.users).map((key) => (
      <li key={key}>
        {props.users[key]["name"]}
        {props.users[key]["fullName"]
          ? " - " + props.users[key]["fullName"]
          : null}
        <small className="text-muted"> ( {props.users[key]["id"]} )</small>
      </li>
    ))}
  </ul>
)

export default Users
