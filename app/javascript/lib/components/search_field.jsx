import { Popover, OverlayTrigger } from "react-bootstrap"
import { SearchInput } from "juno-ui-components"
import React from "react"

let counter = 0

/**
 * This component implements a serach field.
 * Usage: <SearchField placeholder='Name' text='Search by name' onChange={(term) => handleSearch}/>
 **/
export class SearchField extends React.Component {
  state = {
    searchTerm: "",
  }

  infoText = (
    <Popover id={`search_field_${this.props.id || counter++}`}>
      {this.props.text}
    </Popover>
  )

  onChangeTerm = (e) => {
    const value = e.target.value || ""
    this.setState({ searchTerm: value }, () => this.props.onChange(value))
  }

  reset = (e) => {
    e.preventDefault()
    this.setState({ searchTerm: "" }, () => this.props.onChange(""))
  }

  UNSAFE_componentWillReceiveProps = (nextProps) => {
    // console.log('UNSAFE_componentWillReceiveProps',nextProps)
    if (nextProps.value != null) this.setState({ searchTerm: nextProps.value })
  }

  componentDidMount = () => {
    // console.log('componentDidMount',this.props)
    if (this.props.value) this.setState({ searchTerm: this.props.value })
  }

  render() {
    const variant = this.props.variant
    const empty = this.state.searchTerm.trim().length == 0
    const showSearchIcon = this.props.searchIcon != false
    let iconClassName = empty
      ? showSearchIcon
        ? "fa fa-search"
        : ""
      : "fa fa-times-circle"
    if (this.props.isFetching) iconClassName = "spinner"

    return (
      <React.Fragment>
        {variant === "juno" ? (
          <SearchInput
            value={this.state.searchTerm}
            placeholder={this.props.placeholder}
            disabled={this.props.disabled === true}
            onChange={this.onChangeTerm}
            onClear={(e) => this.reset(e)}
          />
        ) : (
          <React.Fragment>
            <div className="has-feedback has-feedback-searchable">
              <input
                data-test="search"
                type="text"
                className="form-control"
                value={this.state.searchTerm}
                placeholder={this.props.placeholder}
                onChange={this.onChangeTerm}
                disabled={this.props.disabled == true}
              />
              <span
                className={`form-control-feedback ${!empty && "not-empty"}`}
                onClick={(e) =>
                  iconClassName != "spinner" && !empty && this.reset(e)
                }
              >
                <i className={iconClassName} />
              </span>
            </div>
            {this.props.text && (
              <div className="has-feedback-help">
                <OverlayTrigger
                  trigger="click"
                  placement="top"
                  rootClose
                  overlay={this.infoText}
                >
                  <a className="help-link" href="#" onClick={() => null}>
                    <i className="fa fa-question-circle"></i>
                  </a>
                </OverlayTrigger>
              </div>
            )}
          </React.Fragment>
        )}
      </React.Fragment>
    )
  }
}
