import React from "react"
import { useDispatch } from "../../components/StateProvider"
import { ajaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"

export const fetchAvailabilityZones = () => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .get(`/loadbalancers/availability-zones`)
      .then((response) => {
        handleSuccess(response.data.availability_zones)
      })
      .catch((error) => {
        handleErrors(error.data)
      })
  })
}

const useLoadbalancer = () => {
  const dispatch = useDispatch()

  const fetchLoadbalancers = (options) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers`, { params: options })
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.data)
        })
    })
  }

  const fetchLoadbalancer = (id) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${id}`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.data)
        })
    })
  }

  const fetchLoadbalancerDevice = (id) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(`/loadbalancers/${id}/device`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleError(error.data)
        })
    })
  }

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

  const findLoadbalancer = (loadbalancers, lbID) => {
    if (loadbalancers) {
      const index = loadbalancers.findIndex((item) => item.id == lbID)
      if (index >= 0) {
        return loadbalancers[index]
      }
    }
    return null
  }

  const createLoadbalancer = (values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .post("/loadbalancers/", { loadbalancer: values })
        .then((response) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: response.data,
          })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateLoadbalancer = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .put(`/loadbalancers/${lbID}`, { loadbalancer: values })
        .then((response) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: response.data,
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

  const deleteLoadbalancer = (name, id) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(
        <React.Fragment>
          <p>
            Do you really want to delete following Load Balancer and all related
            objects?
          </p>
          <p>
            {createNameTag(name)} <b>id:</b> {id}
          </p>
        </React.Fragment>
      )
        .then(() => {
          return ajaxHelper
            .delete(`/loadbalancers/${id}`)
            .then((response) => {
              dispatch({ type: "REQUEST_REMOVE_LOADBALANCER", id: id })
              handleSuccess(response)
            })
            .catch((error) => {
              handleErrors(error)
            })
        })
        .catch((cancel) => true)
    })
  }

  const fetchPrivateNetworks = () => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .get(`/loadbalancers/private-networks`)
        .then((response) => {
          handleSuccess(response.data)
        })
        .catch((error) => {
          handleErrors(error.data)
        })
    })
  }

  const fetchSubnets = (id) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .get(`/loadbalancers/private-networks/${id}/subnets`)
        .then((response) => {
          handleSuccess(response.data.subnets)
        })
        .catch((error) => {
          handleErrors(error.data)
        })
    })
  }

  const fetchFloatingIPs = () => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .get(`/loadbalancers/fips`)
        .then((response) => {
          handleSuccess(response.data.fips)
        })
        .catch((error) => {
          handleErrors(error.data)
        })
    })
  }

  const attachFIP = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      dispatch({ type: "REQUEST_FLOATINGIP_LOADBALANCER", id: lbID })
      ajaxHelper
        .put(`/loadbalancers/${lbID}/attach_fip`, values)
        .then((response) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: response.data,
          })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error.data)
        })
    })
  }

  const detachFIP = (lbID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      dispatch({ type: "REQUEST_FLOATINGIP_LOADBALANCER", id: lbID })
      ajaxHelper
        .put(`/loadbalancers/${lbID}/detach_fip`, values)
        .then((response) => {
          dispatch({
            type: "RECEIVE_LOADBALANCER",
            loadbalancer: response.data,
          })
          handleSuccess(response)
        })
        .catch((error) => {
          handleErrors(error.data)
        })
    })
  }

  const reset = () => {
    dispatch({ type: "SET_LOADBALANCER_SEARCH_TERM", searchTerm: null })
    dispatch({ type: "SET_LOADBALANCERS_SELECTED_ITEM", selected: null })
  }

  return {
    fetchLoadbalancers,
    fetchLoadbalancer,
    fetchLoadbalancerDevice,
    persistLoadbalancers,
    persistLoadbalancer,
    findLoadbalancer,
    deleteLoadbalancer,
    createLoadbalancer,
    updateLoadbalancer,
    fetchPrivateNetworks,
    fetchSubnets,
    fetchFloatingIPs,
    attachFIP,
    detachFIP,
    reset,
  }
}

export default useLoadbalancer
