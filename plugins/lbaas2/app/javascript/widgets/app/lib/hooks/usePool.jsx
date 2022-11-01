import React from "react"
import { ajaxHelper } from "lib/ajax_helper"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import { createNameTag } from "../../helpers/commonHelpers"

const usePool = () => {
  const dispatch = useDispatch()

  const fetchPools = (lbID, options) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${lbID}/pools`, { params: options })
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error)
        })
    })
  }

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

  const fetchPool = (lbID, poolID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${lbID}/pools/${poolID}`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
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
      ajaxHelper
        .post(`/loadbalancers/${lbID}/pools`, { pool: values })
        .then((response) => {
          dispatch({ type: "RECEIVE_POOL", pool: response.data })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updatePool = (lbID, poolID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .put(`/loadbalancers/${lbID}/pools/${poolID}`, { pool: values })
        .then((response) => {
          dispatch({ type: "RECEIVE_POOL", pool: response.data })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const findPool = (pools, poolID) => {
    if (pools) {
      const index = pools.findIndex((item) => item.id == poolID)
      if (index >= 0) {
        return pools[index]
      }
    }
    return null
  }

  const deletePool = (lbID, poolID, poolName) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <React.Fragment>
          <p>Do you really want to delete following Pool?</p>
          <p>
            {createNameTag(poolName)} <b>id:</b> {poolID}
          </p>
        </React.Fragment>
      )
        .then(() => {
          return ajaxHelper
            .delete(`/loadbalancers/${lbID}/pools/${poolID}`)
            .then((response) => {
              dispatch({ type: "REQUEST_REMOVE_POOL", id: poolID })
              handleSuccess(response)
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

  const lbAlgorithmTypes = () => {
    return [
      { label: "LEAST_CONNECTIONS", value: "LEAST_CONNECTIONS" },
      { label: "ROUND_ROBIN", value: "ROUND_ROBIN" },
    ]
  }

  const protocolTypes = () => {
    return [
      { label: "HTTP", value: "HTTP" },
      // Disable HTTPS when creating listeners
      // With Octavia, HTTPS is exactly the same as TCP (it’s been meant to be TLS-HTTP passthrough for the backends, but octavia doesn’t really handles them any different than TCP).
      { label: "HTTPS", value: "HTTPS", state: "disabled" },
      { label: "PROXY", value: "PROXY" },
      { label: "TCP", value: "TCP" },
      { label: "UDP", value: "UDP" },
    ]
  }

  const poolPersistenceTypes = () => {
    return [
      {
        label: "APP_COOKIE",
        value: "APP_COOKIE",
        description:
          "Use the specified cookie_name send future requests to the same member.",
      },
      {
        label: "HTTP_COOKIE",
        value: "HTTP_COOKIE",
        description:
          "The load balancer will generate a cookie that is inserted into the response. This cookie will be used to send future requests to the same member.",
      },
      {
        label: "SOURCE_IP",
        value: "SOURCE_IP",
        description:
          "The source IP address on the request will be hashed to send future requests to the same member.",
      },
    ]
  }

  const poolProtocolListenerCombinations = (poolProtocol) => {
    switch (poolProtocol) {
      case "HTTP":
        return ["HTTP", "TCP", "TERMINATED_HTTPS"]
      case "HTTPS":
        return ["HTTPS", "TCP"]
      case "PROXY":
        return ["HTTP", "HTTPS", "TCP", "TERMINATED_HTTPS"]
      case "TCP":
        return ["HTTPS", "TCP"]
      case "UDP":
        return ["UDP"]
      default:
        return []
    }
  }

  const filterListeners = (listeners, selectedProtocol) => {
    return listeners.filter((i) =>
      poolProtocolListenerCombinations(selectedProtocol).includes(i.protocol)
    )
  }

  return {
    fetchPools,
    persistPools,
    fetchPool,
    persistPool,
    createPool,
    updatePool,
    deletePool,
    onSelectPool,
    setSearchTerm,
    setSelected,
    reset,
    findPool,
    lbAlgorithmTypes,
    protocolTypes,
    poolPersistenceTypes,
    poolProtocolListenerCombinations,
    filterListeners,
  }
}

export default usePool
