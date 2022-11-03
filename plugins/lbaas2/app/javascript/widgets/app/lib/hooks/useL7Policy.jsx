import React from "react"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import { createNameTag } from "../../helpers/commonHelpers"
import {
  fetchL7Policies,
  fetchL7Policy,
  postL7Policy,
  putL7Policy,
  deleteL7Policy,
} from "../../actions/l7Policy"

const useL7Policy = () => {
  const dispatch = useDispatch()

  const persistL7Policies = (lbID, listenerID, options) => {
    dispatch({ type: "RESET_L7POLICIES" })
    dispatch({ type: "REQUEST_L7POLICIES" })
    return new Promise((handleSuccess, handleError) => {
      fetchL7Policies(lbID, listenerID, options)
        .then((data) => {
          dispatch({
            type: "RECEIVE_L7POLICIES",
            items: data.l7policies,
            hasNext: data.has_next,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_L7POLICIES_FAILURE", error: error })
          handleError(error)
        })
    })
  }

  const persistL7Policy = (lbID, listenerID, l7PolicyID) => {
    return new Promise((handleSuccess, handleError) => {
      fetchL7Policy(lbID, listenerID, l7PolicyID)
        .then((data) => {
          dispatch({ type: "RECEIVE_L7POLICY", l7Policy: data.l7policy })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_L7POLICY", id: l7PolicyID })
          }
          handleError(error)
        })
    })
  }

  const createL7Policy = (lbID, listenerID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      postL7Policy(lbID, listenerID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_L7POLICY",
            l7Policy: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateL7Policy = (lbID, listenerID, l7policyID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      putL7Policy(lbID, listenerID, l7policyID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_L7POLICY",
            l7Policy: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const removeL7Policy = (lbID, listenerID, l7policyID, l7policyName) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <React.Fragment>
          <p>Do you really want to delete following L7 Policy?</p>
          <p>
            {createNameTag(l7policyName)} <b>id:</b> {l7policyID}
          </p>
        </React.Fragment>
      )
        .then(() => {
          return deleteL7Policy(lbID, listenerID, l7policyID)
            .then((data) => {
              dispatch({ type: "REQUEST_REMOVE_L7POLICY", id: l7policyID })
              handleSuccess(data)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const onSelectL7Policy = (props, l7PolicyID) => {
    const id = l7PolicyID || ""
    const pathname = props.location.pathname
    const searchParams = new URLSearchParams(props.location.search)
    searchParams.set("l7policy", id)
    props.history.push({
      pathname: pathname,
      search: searchParams.toString(),
    })

    // L7Policy was selected
    setSelected(l7PolicyID)
    // filter list in case we still show the list
    setSearchTerm(l7PolicyID)
  }

  const setSearchTerm = (searchTerm) => {
    dispatch({ type: "SET_L7POLICIES_SEARCH_TERM", searchTerm: searchTerm })
  }

  const setSelected = (item) => {
    dispatch({ type: "SET_L7POLICIES_SELECTED_ITEM", selected: item })
  }

  const reset = () => {
    dispatch({ type: "SET_L7POLICIES_SEARCH_TERM", searchTerm: null })
    dispatch({ type: "SET_L7POLICIES_SELECTED_ITEM", selected: null })
  }

  return {
    createL7Policy,
    updateL7Policy,
    removeL7Policy,
    onSelectL7Policy,
    persistL7Policies,
    persistL7Policy,
    setSearchTerm,
    setSelected,
    reset,
  }
}

export default useL7Policy
