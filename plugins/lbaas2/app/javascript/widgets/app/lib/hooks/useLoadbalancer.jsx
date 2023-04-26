import React from "react"
import { useDispatch } from "../../components/StateProvider"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { createNameTag } from "../../helpers/commonHelpers"
import {
  fetchLoadbalancers,
  fetchLoadbalancer,
  postLoadbalancer,
  putLoadbalancer,
  deleteLoadbalancer,
  putAttachFIP,
  putDetachFIP,
} from "../../actions/loadbalancer"

const useLoadbalancer = () => {
  const dispatch = useDispatch()

  const persistLoadbalancers = (options) => {
    dispatch({ type: "REQUEST_LOADBALANCERS", requestedAt: Date.now() })
    return new Promise((handleSuccess, handleError) => {
      fetchLoadbalancers(options)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LOADBALANCERS",
            loadbalancers: data.loadbalancers,
            has_next: data.has_next,
            limit: data.limit,
            sort_key: data.sort_key,
            sort_dir: data.sort_dir,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_LOADBALANCERS_FAILURE", error: error })
          handleError(error)
        })
    })
  }

  const persistLoadbalancer = (id) => {
    return new Promise((handleSuccess, handleError) => {
      fetchLoadbalancer(id)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: data.loadbalancer,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_LOADBALANCER", id: id })
          }
          handleError(error)
        })
    })
  }

  const createLoadbalancer = (values) => {
    return new Promise((handleSuccess, handleErrors) => {
      postLoadbalancer(values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateLoadbalancer = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      putLoadbalancer(lbID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const removeLoadbalancer = (name, id) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <>
          <p>
            Do you really want to delete following Load Balancer and all related
            objects?
          </p>
          <p>
            {createNameTag(name)} <b>id:</b> {id}
          </p>
        </>
      )
        .then(() => {
          return deleteLoadbalancer(id)
            .then((data) => {
              dispatch({ type: "REQUEST_REMOVE_LOADBALANCER", id: id })
              handleSuccess(data)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const attachFIP = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      dispatch({ type: "REQUEST_FLOATINGIP_LOADBALANCER", id: lbID })
      putAttachFIP(lbID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const detachFIP = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      dispatch({ type: "REQUEST_FLOATINGIP_LOADBALANCER", id: lbID })
      putDetachFIP(lbID, values)
        .then((data) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: data,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const reset = () => {
    dispatch({ type: "SET_LOADBALANCER_SEARCH_TERM", searchTerm: null })
    dispatch({ type: "SET_LOADBALANCERS_SELECTED_ITEM", selected: null })
  }

  return {
    persistLoadbalancers,
    persistLoadbalancer,
    removeLoadbalancer,
    createLoadbalancer,
    updateLoadbalancer,
    attachFIP,
    detachFIP,
    reset,
  }
}

export default useLoadbalancer
