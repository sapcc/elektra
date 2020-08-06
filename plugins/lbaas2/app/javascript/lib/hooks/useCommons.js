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
    const err = error.response || error
    if (err && err.data && err.data.errors && Object.keys(err.data.errors).length) {
      return err.data.errors
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
  
  const errorMessage = (error) => {
    const err = error.response || error
    return err.data &&  (err.data.errors || err.data.error) || err.message
  }

  const helpBlockTextForSelect = (options = []) => {
    return (
      <ul className="help-block-popover-scroll small">
        {options.map( (t, index) =>
          <li key={index}><b>{t.label}</b>: {t.description}</li>
        )}
      </ul>
    )
  }

  const labelStateAttributes = (option) => {
    switch (option) {
      case 'ONLINE':
        return {labelClassName: "label-success", textClassName: "text-success", title: <React.Fragment><ul className="label-tooltip"><li>Entity is operating normally</li><li>All pool members are healthy</li></ul></React.Fragment>}
        
      case 'DRAINING':
        return {labelClassName: "label-warning-greyscale", textClassName: "text-warning-greyscale", title: "The member is not accepting new connections"}
      case 'DEGRADED':      
        return {labelClassName: "label-warning-greyscale", textClassName: "text-warning-greyscale", title: "One or more of the entity’s components are in ERROR"}
      case 'OFFLINE':
        return {labelClassName: "label-warning-greyscale", textClassName: "text-warning-greyscale", title: "Entity is administratively disabled"}
      case 'NO_MONITOR':
        return {labelClassName: "label-warning-greyscale", textClassName: "text-warning-greyscale", title: "No health monitor is configured for this entity and it’s status is unknown"}
  
      case 'ERROR':
        return {labelClassName: "label-danger", textClassName: "text-danger", title: <React.Fragment><ul className="label-tooltip"><li>The entity has failed</li><li>The member is failing it’s health monitoring checks</li><li>All of the pool members are in ERROR</li></ul></React.Fragment>}
      default:
        return {labelClassName: 'label-info', textClassName: "text-info", title: "Unknown state"}
    }
  }

  const labelStatusAttributes = (option) => {
    switch (option) {
      case 'ACTIVE':
        return {labelClassName: "label-success", textClassName: "text-success", title: "The entity was provisioned successfully"}
      case 'DELETED':
        return {labelClassName: "label-success", textClassName: "text-success", title: "The entity has been successfully deleted"}
  
      case 'ERROR':
        return {labelClassName: "label-danger", textClassName: "text-danger", title: "Provisioning failed"}
  
      case "PENDING_CREATE":
        return {labelClassName: 'label-warning', textClassName: "text-warning", title: "The entity is being created"}
      case "PENDING_UPDATE":
        return {labelClassName: 'label-warning', textClassName: "text-warning", title: "TThe entity is being updated"}
      case "PENDING_DELETE":
        return {labelClassName: 'label-warning', textClassName: "text-warning", title: "The entity is being deleted"}
      default:
        return {labelClassName: 'label-info', textClassName: "text-info", title: "Unknown state"}
    }
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
    labelStateAttributes,
    labelStatusAttributes
  }
}
 
export default useCommons;