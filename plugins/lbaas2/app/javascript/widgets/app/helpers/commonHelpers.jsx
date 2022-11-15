import React from "react"
import queryString from "query-string"
import { Highlighter } from "react-bootstrap-typeahead"

export const errorMessage = (error) => {
  const err = error
  return (err.data && (err.data.errors || err.data.error)) || err.message
}

export const formErrorMessage = (error) => {
  const err = error
  if (
    err &&
    err.data &&
    err.data.errors &&
    Object.keys(err.data.errors).length
  ) {
    return err.data.errors
  } else {
    return error.message
  }
}

export const createNameTag = (name) => {
  return name ? (
    <React.Fragment>
      <b>name:</b> {name} <br />
    </React.Fragment>
  ) : (
    ""
  )
}

export const secretRefLabel = (secretRef) => {
  const label = secretRef || ""
  return label.replace(/.*\/\/[^\/]*/, "https://...")
}

export const toManySecretsWarning = (total, length) => {
  total = total || 0
  length = length || 0
  if (total > length) {
    return (
      <div className="alert alert-warning">
        This project has <b>{total}</b> secrets and it is not possible to
        display all of them. If you don't find the secret you are looking for
        enter the secret ref manually. <br />
        Ex: https://keymanager-3.region.cloud.sap:443/v1/secrets/secretID
      </div>
    )
  }
}

export const sortObjectByKeys = (o) => {
  return Object.keys(o)
    .sort()
    .reduce((r, k) => ((r[k] = o[k]), r), {})
}

export const helpBlockTextForSelect = (options = []) => {
  return (
    <ul className="help-block-popover-scroll small">
      {options.map((t, index) => (
        <li key={index}>
          <b>{t.label}</b>: {t.description}
        </li>
      ))}
    </ul>
  )
}

export const matchParams = (props) => {
  return (props.match && props.match.params) || {}
}

export const queryStringSearchValues = (props) => {
  return queryString.parse(props.location.search)
}

export const searchParamsToString = (props) => {
  const searchParams = new URLSearchParams(props.location.search)
  return searchParams.toString()
}

export const MyHighlighter = ({ search, children }) => {
  if (!search || !children) return children
  return <Highlighter search={search}>{children + ""}</Highlighter>
}
