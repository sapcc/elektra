import React from 'react';
import queryString from 'query-string'

const useCommons = () => {

  const searchParamsToString = (props) => {
    const searchParams = new URLSearchParams(props.location.search);
    return searchParams.toString()
  }

  const queryStringSearchValues = (props) => {
    return queryString.parse(props.location.search)
  }

  return {
    searchParamsToString,
    queryStringSearchValues
  }
}
 
export default useCommons;