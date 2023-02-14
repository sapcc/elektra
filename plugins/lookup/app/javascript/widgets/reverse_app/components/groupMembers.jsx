import React from "react"
const GroupMembers = (props) => (
  <React.Fragment>
    {props.members.isFetching && <span className="spinner" />}
    {props.members.error && (
      <span className="text-danger">{props.members.error.error}</span>
    )}
    {props.members.data && (
      <ul className="plain-list plain-list-widespaced">
        {Object.keys(props.members.data).map((key) => (
          <li key={key}>
            {props.members.data[key]["name"]}
            {props.members.data[key]["fullName"]
              ? " - " + props.members.data[key]["fullName"]
              : null}
            <small className="text-muted">
              {" "}
              ( {props.members.data[key]["id"]} )
            </small>
          </li>
        ))}
      </ul>
    )}
  </React.Fragment>
)

export default GroupMembers
