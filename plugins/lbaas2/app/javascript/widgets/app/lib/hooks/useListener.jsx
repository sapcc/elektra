import React from "react"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import {
  fetchListeners,
  fetchListener,
  postListener,
  putListener,
  deleteListener,
} from "../../actions/listener"
import { createNameTag } from "../../helpers/commonHelpers"

const useListener = () => {
  const dispatch = useDispatch()

  const persistListeners = (lbID, shouldReset, options) => {
    if (shouldReset) {
      dispatch({ type: "RESET_LISTENERS" })
    }
    dispatch({ type: "REQUEST_LISTENERS" })
    return new Promise((handleSuccess, handleError) => {
      fetchListeners(lbID, options)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LISTENERS",
            items: data.listeners,
            has_next: data.has_next,
            limit: data.limit,
            sort_key: data.sort_key,
            sort_dir: data.sort_dir,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_LISTENERS_FAILURE", error: error })
          handleError(error)
        })
    })
  }

  const persistListener = (lbID, id) => {
    return new Promise((handleSuccess, handleError) => {
      fetchListener(lbID, id)
        .then((data) => {
          dispatch({ type: "RECEIVE_LISTENER", listener: data.listener })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_LISTENER", id: id })
          }
          handleError(error)
        })
    })
  }

  const createListener = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      postListener(lbID, values)
        .then((data) => {
          dispatch({ type: "RECEIVE_LISTENER", listener: data })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateListener = (lbID, listenerID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      putListener(lbID, listenerID, values)
        .then((data) => {
          dispatch({ type: "RECEIVE_LISTENER", listener: data })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const removeListener = (lbID, listenerID, listenerName) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <React.Fragment>
          <p>Do you really want to delete following Listener?</p>
          <p>
            {createNameTag(listenerName)} <b>id:</b> {listenerID}
          </p>
        </React.Fragment>
      )
        .then(() => {
          deleteListener(lbID, listenerID)
            .then((data) => {
              dispatch({ type: "REQUEST_REMOVE_LISTENER", id: listenerID })
              handleSuccess(data)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const setSearchTerm = (searchTerm) => {
    dispatch({ type: "SET_LISTENERS_SEARCH_TERM", searchTerm: searchTerm })
  }

  const setSelected = (item) => {
    dispatch({ type: "SET_LISTENERS_SELECTED_ITEM", selected: item })
  }

  const reset = () => {
    dispatch({ type: "SET_LISTENERS_SEARCH_TERM", searchTerm: null })
    dispatch({ type: "SET_LISTENERS_SELECTED_ITEM", selected: null })
  }

  const onSelectListener = (props, listenerID) => {
    const id = listenerID || ""
    const pathname = props.location.pathname
    const searchParams = new URLSearchParams(props.location.search)
    searchParams.set("listener", id)
    if (id == "") {
      // if listener was unselected then we remove the policy selection
      searchParams.set("l7policy", "")
    }
    props.history.push({
      pathname: pathname,
      search: searchParams.toString(),
    })
    // Listener was selected
    setSelected(listenerID)
    // filter the listener list to show just the one item
    setSearchTerm(listenerID)
  }

  return {
    persistListeners,
    persistListener,
    createListener,
    updateListener,
    removeListener,
    onSelectListener,
    setSearchTerm,
    setSelected,
    reset,
  }
}

export default useListener
