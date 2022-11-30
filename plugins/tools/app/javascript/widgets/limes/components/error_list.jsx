import { Link } from "react-router-dom"
import { DataTable } from "lib/components/datatable"
import React from "react"
import { LIMES_ERROR_TYPES } from "../constants"
import ErrorRow from "./error_row"

const formatErrorTypeForDisplay = (errorType) => {
  //e.g. "resource-scrape-errors" -> "Resource Scrape Errors"
  return errorType
    .replace(/-/g, " ")
    .replace(/\b\w/g, (txt) => txt.toUpperCase())
}

const columnDefs = [
  {
    key: "service",
    label: "Service type",
    sortStrategy: "text",
    sortKey: (props) => props.error.service_type,
  },
  {
    key: "timestamp",
    label: "Scrape failed at",
    sortStrategy: "numeric",
    sortKey: (props) => props.error.checked_at || 0,
  },
  {
    key: "project",
    label: "Project",
    sortStrategy: "text",
    sortKey: (props) =>
      `${props.error.project.domain.name}/${props.error.project.name}`,
  },
]

export default class Loader extends React.Component {
  componentDidMount() {
    this.props.fetchAllErrorsAsNeeded()
  }
  componentDidUpdate() {
    this.props.fetchAllErrorsAsNeeded()
  }

  render() {
    const { errorType: currentErrorType } = this.props

    return (
      <React.Fragment>
        <nav className="nav-with-buttons">
          <ul className="nav nav-tabs">
            {LIMES_ERROR_TYPES.map((errorType) => (
              <li
                key={errorType}
                role="presentation"
                className={errorType == currentErrorType ? "active" : ""}
              >
                <Link to={`/${errorType}`}>
                  {formatErrorTypeForDisplay(errorType)}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
        {this.renderContent()}
      </React.Fragment>
    )
  }

  renderContent() {
    const { errorType, isFetching, data, errorMessage } = this.props
    if (isFetching) {
      return (
        <p>
          <span className="spinner" /> Loading errors...
        </p>
      )
    }
    if (errorMessage !== null) {
      return (
        <p className="alert alert-danger">
          Could not load errors: {errorMessage}
        </p>
      )
    }

    return (
      <DataTable className="limes-error-list" columns={columnDefs} pageSize={6}>
        {data.map((error, idx) => (
          <ErrorRow key={`error${idx}`} error={error} />
        ))}
      </DataTable>
    )

    return <pre>{JSON.stringify(data, null, 2)}</pre>
  }
}
