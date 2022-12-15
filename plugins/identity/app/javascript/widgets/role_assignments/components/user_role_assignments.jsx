import { SearchField } from "lib/components/search_field"
import { regexString } from "lib/tools/regex_string"
import { Highlighter } from "react-bootstrap-typeahead"
import React from "react"

export default class UserRoleAssignments extends React.Component {
  state = {
    filterString: "",
  }

  componentDidMount() {
    this.props.loadUserRoleAssignments()
  }

  sortData = () => {
    if (!this.props.items) return []
    const assignments = {}

    for (let item of this.props.items) {
      let key = item.scope && item.scope.domain && item.scope.domain.id
      if (!key)
        key =
          item.scope &&
          item.scope &&
          item.scope.project &&
          item.scope.project.id

      assignments[key] = assignments[key] || {}
      assignments[key]["domain"] =
        item.scope &&
        (item.scope.domain || (item.scope.project && item.scope.project.domain))
      assignments[key]["project"] = item.scope && item.scope.project
      assignments[key]["roles"] = assignments[key]["roles"] || []
      assignments[key]["roles"].push(item.role)

      assignments[key]["scope_slug"] = ""
      if (
        item.scope &&
        (item.scope.domain || (item.scope.project && item.scope.project.domain))
      )
        assignments[key]["scope_slug"] += (
          item.scope.domain ||
          (item.scope.project && item.scope.project.domain)
        ).name
      if (item.scope && item.scope.project)
        assignments[key]["scope_slug"] += `/${item.scope.project.name}`
    }

    let data = Object.values(assignments).sort((a, b) => {
      if (a.scope_slug.toLowerCase() < b.scope_slug.toLowerCase()) return -1
      if (a.scope_slug.toLowerCase() > b.scope_slug.toLowerCase()) return 1
      return 0
    })

    if (!this.state.filterString || this.state.filterString.length == 0)
      return data

    return data.filter((item) => {
      if (this.state.filterString && this.state.filterString.length > 0) {
        const regex = new RegExp(
          regexString(this.state.filterString.trim()),
          "i"
        )
        return `${item.scope_slug} ${item.roles
          .map((r) => r.name)
          .join(",")}`.match(regex)
      }
    })
  }

  render() {
    const data = this.sortData()

    return (
      <React.Fragment>
        <div className="toolbar">
          {this.props.items && this.props.items.length > 0 && (
            <React.Fragment>
              <SearchField
                onChange={(term) => this.setState({ filterString: term })}
                placeholder={`Name ${
                  this.props.type == "user" ? ", C/D/I-number, " : ""
                } or ID`}
                isFetching={false}
                searchIcon={true}
                text={`Filter ${this.props.type}s by name or id`}
              />
              <span className="toolbar-input-divider"></span>
            </React.Fragment>
          )}

          {this.props.isFetching && (
            <div className="toolbar-container">
              <span className="spinner"></span>Loading ...
            </div>
          )}
        </div>

        {!this.props.isFetching && data.length > 0 ? (
          <table className="table">
            <thead>
              <tr>
                <th>Scope</th>
                <th>Roles</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, index) => (
                <tr key={index}>
                  <td>
                    <b>
                      <Highlighter search={this.state.filterString}>
                        {item.scope_slug}
                      </Highlighter>
                    </b>
                    <br />
                    <span className="info-text">
                      {
                        (
                          item.domain ||
                          (item.project && item.project.domain) ||
                          {}
                        ).id
                      }
                      {item.project &&
                        item.project.id &&
                        ` / ${item.project.id}`}
                    </span>
                  </td>
                  <td>
                    <Highlighter search={this.state.filterString}>
                      {item.roles.map((role) => role.name).join(", ")}
                    </Highlighter>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          !this.props.isFetching &&
          data.length == 0 && <p>No role assignments found</p>
        )}
      </React.Fragment>
    )
  }
}
