import { Link } from "react-router-dom"
import { DefeatableLink } from "lib/components/defeatable_link"
import { Popover, OverlayTrigger, Tooltip } from "react-bootstrap"
import { TransitionGroup, CSSTransition } from "react-transition-group"
import { FadeTransition } from "lib/components/transitions"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import Item from "./item"
import { AjaxPaginate } from "lib/components/ajax_paginate"

const TableRowFadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={200} classNames="css-transition-fade">
    {children}
  </CSSTransition>
)

export default class List extends React.Component {
  state = {}

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies(props) {
    if (!props.active) return
    props.loadSnapshotsOnce()
  }

  filterItems = () => {
    let { items = [], searchTerm } = this.props.snapshots
    if (!searchTerm) return items

    // filter items
    const regex = new RegExp(searchTerm.trim(), "i")

    return items.filter(
      (i) =>
        `${i.id} ${i.name} ${i.description} ${i.volume_id} ${i.size} ${i.status}`.search(
          regex
        ) >= 0
    )
  }

  render() {
    const { hasNext, isFetching, searchTerm } = this.props.snapshots
    const items = this.filterItems()

    return (
      <React.Fragment>
        {this.props.snapshots.items.length > 5 && (
          <div className="toolbar">
            <SearchField
              onChange={(term) => this.props.search(term)}
              placeholder="name, ID, format or status"
              text="Searches by name, ID, format or status in visible snapshots list only.
              Entering a search term will automatically start loading the next pages
              and filter the loaded items using the search term. Emptying the search
              input field will show all currently loaded items."
            />
          </div>
        )}

        <table className="table snapshots">
          <thead>
            <tr>
              <th>Snapshot</th>
              <th>Description</th>
              <th>Size(GB)</th>
              <th>Source Volume</th>
              <th>Status</th>
              <th className="snug"></th>
            </tr>
          </thead>
          <tbody>
            {items && items.length > 0 ? (
              items.map((snapshot, index) => (
                <Item
                  snapshot={snapshot}
                  key={index}
                  searchTerm={searchTerm}
                  reloadSnapshot={this.props.reloadSnapshot}
                  deleteSnapshot={this.props.deleteSnapshot}
                />
              ))
            ) : (
              <tr>
                <td colSpan="6">
                  {isFetching ? (
                    <span className="spinner" />
                  ) : (
                    "No snapshots found."
                  )}
                </td>
              </tr>
            )}
          </tbody>
        </table>

        <AjaxPaginate
          hasNext={hasNext}
          isFetching={isFetching}
          onLoadNext={this.props.loadNext}
        />
      </React.Fragment>
    )
  }
}
