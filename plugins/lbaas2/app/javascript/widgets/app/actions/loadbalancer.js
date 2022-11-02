import { ajaxHelper } from "lib/ajax_helper"

export const fetchAvailabilityZones = () => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .get(`/loadbalancers/availability-zones`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchLoadbalancers = (options) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers`, { params: options })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchLoadbalancer = (id) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${id}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const postLoadbalancer = (values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post("/loadbalancers/", { loadbalancer: values })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const putLoadbalancer = (lbID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(`/loadbalancers/${lbID}`, { loadbalancer: values })
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const deleteLoadbalancer = (id) => {
  return new Promise((handleSuccess, handleErrors) => {
    return ajaxHelper
      .delete(`/loadbalancers/${id}`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchPrivateNetworks = () => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .get(`/loadbalancers/private-networks`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchSubnets = (id) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .get(`/loadbalancers/private-networks/${id}/subnets`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchFloatingIPs = () => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .get(`/loadbalancers/fips`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const fetchLoadbalancerDevice = (id) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(`/loadbalancers/${id}/device`)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const putAttachFIP = (lbID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(`/loadbalancers/${lbID}/attach_fip`, values)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const putDetachFIP = (lbID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(`/loadbalancers/${lbID}/detach_fip`, values)
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}
