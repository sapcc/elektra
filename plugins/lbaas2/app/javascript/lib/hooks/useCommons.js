import React from "react"
import queryString from "query-string"
import { Highlighter } from "react-bootstrap-typeahead"
import { ajaxHelper } from "lib/ajax_helper"

const useCommons = () => {
  const MyHighlighter = ({ search, children }) => {
    if (!search || !children) return children
    return <Highlighter search={search}>{children + ""}</Highlighter>
  }

  const searchParamsToString = (props) => {
    const searchParams = new URLSearchParams(props.location.search)
    return searchParams.toString()
  }

  const queryStringSearchValues = (props) => {
    return queryString.parse(props.location.search)
  }

  const matchParams = (props) => {
    return (props.match && props.match.params) || {}
  }

  const formErrorMessage = (error) => {
    const err = error.response || error
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

  const fetchPoolsForSelect = (lbID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${lbID}/pools/items_for_select`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(formErrorMessage(error))
        })
    })
  }

  const errorMessage = (error) => {
    const err = error.response || error
    return (err.data && (err.data.errors || err.data.error)) || err.message
  }

  const helpBlockTextForSelect = (options = []) => {
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

  const sortObjectByKeys = (o) => {
    return Object.keys(o)
      .sort()
      .reduce((r, k) => ((r[k] = o[k]), r), {})
  }

  return {
    MyHighlighter,
    searchParamsToString,
    queryStringSearchValues,
    matchParams,
    formErrorMessage,
    fetchPoolsForSelect,
    errorMessage,
    helpBlockTextForSelect,
    sortObjectByKeys,
  }
}

export default useCommons
