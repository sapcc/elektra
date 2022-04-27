import {
  AsyncTypeahead,
  Highlighter,
  Menu,
  MenuItem,
} from "react-bootstrap-typeahead"
import { pluginAjaxHelper } from "lib/ajax_helper"

const liveSearchEndpoints = {
  users: "/identity/domains/users.json",
  groups: "/identity/groups.json",
}
const ajaxHelper = pluginAjaxHelper("/")

export class AutocompleteField extends React.Component {
  state = {
    isLoading: false,
    options: [],
    liveSearchResults: null,
  }

  // handleSearch calls first the elektra cache and if no results are returned it calls
  // the identity to search for groups or users (ONLY FOR groups or users)
  handleSearch = (searchTerm) => {
    let path
    switch (this.props.type) {
      case "projects":
        path = "projects"
        break
      case "users":
        path = "users"
        break
      case "groups":
        path = "groups"
        break
    }

    const params = { term: searchTerm }
    if (this.props.domainId) params["domain"] = this.props.domainId

    this.setState({ isLoading: true, options: [] })
    ajaxHelper
      .get(`/cache/${path}`, { params })
      .then((response) => {
        // return response data unless empty
        if (response.data && response.data.length > 0) return response.data

        // return empty array if live search is deactivated or type is not equal to groups or users
        if (
          !this.props.liveSearch ||
          Object.keys(liveSearchEndpoints).indexOf(this.props.type) < 0
        )
          return []

        // return results from last live search (live search cache)
        if (
          this.state.liveSearchResults &&
          this.state.liveSearchResults[this.props.type]
        )
          return this.state.liveSearchResults[this.props.type]

        return ajaxHelper
          .get(liveSearchEndpoints[this.props.type])
          .then((response) => {
            if (!response.data) return []

            const result = response.data.map((d) => ({
              id: d.id,
              name: d.name,
              full_name: d.description,
            }))

            const newLiveSearchResults = {
              ...this.state.liveSearchResults,
              [this.props.type]: result,
            }
            this.setState({
              ...this.state,
              liveSearchResults: newLiveSearchResults,
            })
            return result
          })
      })
      .then((data) => {
        if (!data) return []

        // convert results to options
        const options = data.map((i) => ({
          name: i.name,
          id: i.uid || i.key || i.id,
          full_name: i.full_name || "",
        }))

        this.setState({ isLoading: false, options: options })
      })

      .catch((error) => console.info("ERROR:", error))
  }

  render() {
    let placeholder = "name or ID"
    if (this.props.type == "projects") placeholder = `Project ${placeholder}`
    else if (this.props.type == "users") placeholder = `User ${placeholder}`
    else if (this.props.type == "groups") placeholder = `Group ${placeholder}`
    return (
      <AsyncTypeahead
        id={(Math.random() + 1).toString(36).substring(7)}
        disabled={!!this.props.disabeld}
        isLoading={this.state.isLoading}
        options={this.state.options}
        clearButton={!!this.props.clearButton}
        autoFocus={true}
        allowNew={false}
        multiple={false}
        onChange={this.props.onSelected}
        onInputChange={this.props.onInputChange}
        onSearch={this.handleSearch}
        labelKey="name"
        filterBy={["id", "name", "full_name"]}
        placeholder={placeholder}
        renderMenuItemChildren={(option, props, index) => {
          return [
            <Highlighter key="name" search={props.text}>
              {option.full_name
                ? `${option.full_name} (${option.name})`
                : option.name}
            </Highlighter>,
            <div className="info-text" key="id">
              <small>ID: {option.id}</small>
            </div>,
          ]
        }}
      />
    )
  }
}
