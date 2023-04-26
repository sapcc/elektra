import React from "react"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import { createNameTag } from "../../helpers/commonHelpers"
import {
  fetchPools,
  fetchPool,
  postPool,
  putPool,
  deletePool,
} from "../../actions/pool"

const usePool = () => {
  const dispatch = useDispatch()

  const persistPools = (lbID, shouldReset, options) => {
    if (shouldReset) {
      dispatch({ type: "RESET_POOLS" })
    }
    dispatch({ type: "REQUEST_POOLS" })
    return new Promise((handleSuccess, handleError) => {
      fetchPools(lbID, options)
        .then((data) => {
          dispatch({
            type: "RECEIVE_POOLS",
            items: data.pools,
            has_next: data.has_next,
            limit: data.limit,
            sort_key: data.sort_key,
            sort_dir: data.sort_dir,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_POOLS_FAILURE", error: error })
          handleError(error)
        })
    })
  }

  const persistPool = (lbID, poolID) => {
    return new Promise((handleSuccess, handleError) => {
      fetchPool(lbID, poolID)
        .then((data) => {
          dispatch({ type: "RECEIVE_POOL", pool: data.pool })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_POOL", id: poolID })
          }
          handleError(error)
        })
    })
  }

  const createPool = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      postPool(lbID, values)
        .then((data) => {
          dispatch({ type: "RECEIVE_POOL", pool: data })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updatePool = (lbID, poolID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      putPool(lbID, poolID, values)
        .then((data) => {
          dispatch({ type: "RECEIVE_POOL", pool: data })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const removePool = (lbID, poolID, poolName) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <>
          <p>Do you really want to delete following Pool?</p>
          <p>
            {createNameTag(poolName)} <b>id:</b> {poolID}
          </p>
        </>
      )
        .then(() => {
          deletePool(lbID, poolID)
            .then((data) => {
              dispatch({ type: "REQUEST_REMOVE_POOL", id: poolID })
              handleSuccess(data)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const onSelectPool = (props, poolID) => {
    const id = poolID || ""
    const pathname = props.location.pathname
    const searchParams = new URLSearchParams(props.location.search)
    searchParams.set("pool", id)
    props.history.push({
      pathname: pathname,
      search: searchParams.toString(),
    })
    // pool was selected
    setSelected(poolID)
    // filter the pool list to show just the one item
    setSearchTerm(poolID)
  }

  const setSearchTerm = (searchTerm) => {
    dispatch({ type: "SET_POOLS_SEARCH_TERM", searchTerm: searchTerm })
  }

  const setSelected = (item) => {
    dispatch({ type: "SET_POOLS_SELECTED_ITEM", selected: item })
  }

  const reset = () => {
    dispatch({ type: "SET_POOLS_SEARCH_TERM", searchTerm: null })
    dispatch({ type: "SET_POOLS_SELECTED_ITEM", selected: null })
  }

  return {
    persistPools,
    persistPool,
    createPool,
    updatePool,
    removePool,
    onSelectPool,
    setSearchTerm,
    setSelected,
    reset,
  }
}

export default usePool
