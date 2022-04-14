import React from "react"
import { ajaxHelper } from "lib/ajax_helper"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import useListener from "./useListener"

const useL7Policy = () => {
  const dispatch = useDispatch()

  const fetchL7Policies = (lbID, listenerID, options) => {
    return new Promise((handleSuccess, handleError) => {
      const params = {}
      ajaxHelper
        .get(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies`, {
          params: options,
        })
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.response)
        })
    })
  }

  const fetchL7Policy = (lbID, listenerID, l7PolicyID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(
          `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}`
        )
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.response)
        })
    })
  }

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
      ajaxHelper
        .post(`/loadbalancers/${lbID}/listeners/${listenerID}/l7policies`, {
          l7policy: values,
        })
        .then((response) => {
          dispatch({
            type: "RECEIVE_L7POLICY",
            l7Policy: response.data.l7policy,
          })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateL7Policy = (lbID, listenerID, l7policyID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .put(
          `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7policyID}`,
          { l7policy: values }
        )
        .then((response) => {
          dispatch({
            type: "RECEIVE_L7POLICY",
            l7Policy: response.data.l7policy,
          })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const createNameTag = (name) => {
    return name ? (
      <React.Fragment>
        <b>name:</b> {name} <br />
      </React.Fragment>
    ) : (
      ""
    )
  }

  const deleteL7Policy = (lbID, listenerID, l7policyID, l7policyName) => {
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
          return ajaxHelper
            .delete(
              `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7policyID}`
            )
            .then((response) => {
              dispatch({ type: "REQUEST_REMOVE_L7POLICY", id: l7policyID })
              handleSuccess(response)
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

  const actionTypes = () => {
    return [
      { value: "REDIRECT_PREFIX", label: "REDIRECT_PREFIX" },
      { value: "REDIRECT_TO_POOL", label: "REDIRECT_TO_POOL" },
      { value: "REDIRECT_TO_URL", label: "REDIRECT_TO_URL" },
      { value: "REJECT", label: "REJECT" },
    ]
  }

  const codeTypes = () => {
    return [
      { value: "301", label: "301" },
      { value: "302", label: "302" },
      { value: "303", label: "303" },
      { value: "307", label: "307" },
      { value: "308", label: "308" },
    ]
  }

  const actionRedirect = (action) => {
    switch (action) {
      case "REDIRECT_PREFIX":
        return [
          { value: "redirect_http_code", label: "HTTP Code" },
          { value: "redirect_prefix", label: "Prefix" },
        ]
      case "REDIRECT_TO_POOL":
        return [{ value: "redirect_pool_id", label: "Pool ID" }]
      case "REDIRECT_TO_URL":
        return [
          { value: "redirect_http_code", label: "HTTP Code" },
          { value: "redirect_url", label: "URL" },
        ]
      default:
        return []
    }
  }

  return {
    fetchL7Policies,
    fetchL7Policy,
    createL7Policy,
    updateL7Policy,
    deleteL7Policy,
    onSelectL7Policy,
    actionRedirect,
    persistL7Policies,
    persistL7Policy,
    setSearchTerm,
    setSelected,
    actionTypes,
    codeTypes,
    reset,
  }
}

export default useL7Policy
