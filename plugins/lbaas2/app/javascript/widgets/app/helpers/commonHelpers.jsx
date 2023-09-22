/* eslint-disable react/no-unescaped-entities */
import React from "react"
import queryString from "query-string"
import { Highlighter } from "react-bootstrap-typeahead"

export const errorMessage = (error) => {
  return (
    error?.data?.errors ||
    error?.data?.error ||
    error?.message ||
    JSON.stringify(error)
  )
}

export const formErrorMessage = (error) => {
  if (error?.data?.errors && Object.keys(error.data.errors).length > 0) {
    return error.data.errors
  } else {
    return error?.message || JSON.stringify(error)
  }
}

export const createNameTag = (name) => {
  return name ? (
    <>
      <b>name:</b> {name} <br />
    </>
  ) : (
    ""
  )
}

export const secretRefLabel = (secretRef) => {
  const label = secretRef || ""
  return label.replace(/.*\/\/[^/]*/, "https://...")
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
