import { Link } from "react-router-dom"
import { DefeatableLink } from "lib/components/defeatable_link"
import { Popover, OverlayTrigger, Tooltip } from "react-bootstrap"
import { TransitionGroup, CSSTransition } from "react-transition-group"
import { FadeTransition } from "lib/components/transitions"
import { policy } from "policy"
import { SearchField } from "lib/components/search_field"
import Item from "./item"
import { AjaxPaginate } from "lib/components/ajax_paginate"

const TableRowFadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={200} classNames="css-transition-fade">
    {children}
  </CSSTransition>
)

export default class List extends React.Component {
  state = {
    visibilityFilters: ["private", "public", "shared"],
    activeFilter: null,
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    if (nextProps.items && nextProps.items.length > 0) {
      // build available filters array
      let availableFilters = this.state.visibilityFilters.slice()
      for (let i of nextProps.items) {
        if (availableFilters.indexOf(i.visibility) < 0)
          availableFilters.push(i.visibility)
      }
      availableFilters.sort()
      let index = availableFilters.indexOf("public")
      if (index < 0) index = 0

      let activeFilter = this.state.activeFilter || availableFilters[index]
      // set available filters and set active filter to the first
      this.setState({
        visibilityFilters: availableFilters,
        activeFilter: activeFilter,
      })
    }
    this.loadDependencies(nextProps)
  }

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies(props) {
    if (!props.active) return
    props.loadOsImagesOnce()
  }

  changeActiveFilter = (name) => {
    // set active filter in state to the name
    this.setState({ activeFilter: name })
  }

  filterItems = () => {
    // filter items dependent on the active filter
    let items = this.props.items.filter(
      (i) => this.state.activeFilter == i.visibility
    )

    if (!this.props.searchTerm) return items

    // search term is given -> filter items dependent on the search term
    const regex = new RegExp(this.props.searchTerm.trim(), "i")
    return items.filter(
      (i) => `${i.name} ${i.id} ${i.format} ${i.status}`.search(regex) >= 0
    )
  }

  toolbar = () => {
    // return null if no items available
    if (this.props.items.length <= 0) return null

    return (
      <div className="toolbar">
        <SearchField
          onChange={(term) => this.props.searchOsImages(term)}
          placeholder="name, ID, format or status"
          text="Searches by name, ID, format or status in visible images list only.
                Entering a search term will automatically start loading the next pages
                and filter the loaded items using the search term. Emptying the search
                input field will show all currently loaded items."
        />
        {this.state.visibilityFilters.length > 1 && ( // show filter checkboxes
          <React.Fragment>
            <span className="toolbar-input-divider"></span>
            <label>Show:</label>
            {this.state.visibilityFilters.map((name, index) => (
              <label className="radio-inline" key={index}>
                <input
                  type="radio"
                  onChange={() => this.changeActiveFilter(name)}
                  checked={this.state.activeFilter == name}
                />
                {name}
              </label>
            ))}
          </React.Fragment>
        )}
      </div>
    )
  }

  renderTable = () => {
    let items = this.filterItems()

    return (
      <div>
        <table className="table shares">
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Format</th>
              <th>Size</th>
              <th>Created</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <TransitionGroup component="tbody">
            {items && items.length > 0 ? (
              items.map(
                (image, index) =>
                  !image.isHidden && (
                    <TableRowFadeTransition key={index}>
                      <Item
                        {...this.props}
                        image={image}
                        handleAccept={this.props.handleAccept}
                        handleReject={this.props.handleReject}
                        activeTab={this.props.activeTab}
                      />
                    </TableRowFadeTransition>
                  )
              )
            ) : (
              <TableRowFadeTransition>
                <tr>
                  <td colSpan="7">
                    {this.props.isFetching ? (
                      <span className="spinner" />
                    ) : (
                      "No images found."
                    )}
                  </td>
                </tr>
              </TableRowFadeTransition>
            )}
          </TransitionGroup>
        </table>

        <AjaxPaginate
          hasNext={this.props.hasNext}
          isFetching={this.props.isFetching}
          onLoadNext={this.props.loadNext}
        />
      </div>
    )
  }

  render() {
    return (
      <div>
        {this.toolbar()}
        {!policy.isAllowed("image:image_list") ? (
          <span>You are not allowed to see this page</span>
        ) : (
          this.renderTable()
        )}
      </div>
    )
  }
}
