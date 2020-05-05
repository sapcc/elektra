import React from 'react';
import queryString from 'query-string'
import { Highlighter } from 'react-bootstrap-typeahead'
import { ajaxHelper } from 'ajax_helper';

const useCommons = () => {

  const MyHighlighter = ({search,children}) => {
    if(!search || !children) return children
    return <Highlighter search={search}>{children+''}</Highlighter>
  }

  const searchParamsToString = (props) => {
    const searchParams = new URLSearchParams(props.location.search);
    return searchParams.toString()
  }

  const queryStringSearchValues = (props) => {
    return queryString.parse(props.location.search)
  }

  const matchParams = (props) => {
    return (props.match && props.match.params) || {}
  }

  const formErrorMessage = (error) => {
    if (error.response && error.response.data && error.response.data.errors && Object.keys(error.response.data.errors).length) {
      return error.response.data.errors
    } else {
      return error.message
    }
  }

  const fetchPoolsForSelect = (lbID) => {
    return new Promise((handleSuccess,handleError) => {  
      ajaxHelper.get(`/loadbalancers/${lbID}/pools/items_for_select`).then((response) => {
        handleSuccess(response.data)
      })
      .catch( (error) => {
        handleError(formErrorMessage(error))
      })
    })
  }
  
  return {
    MyHighlighter,
    searchParamsToString,
    queryStringSearchValues,
    matchParams,
    formErrorMessage,
    fetchPoolsForSelect
  }
}
 
export default useCommons;