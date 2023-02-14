/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import ReactHelpers from "../lib/helpers"
import { saveAs } from "file-saver"
import * as constants from "../constants"
import { ajaxHelper, backendAjaxClient } from "./ajax_helper"
import ReactModal from "../lib/modal"
import { loadMetaData } from "./meta_data"
import { loadInfo } from "./info"
import { showConfirmDialog } from "./dialogs"
//################### CLUSTERS #########################
// ---- list ----
const requestClusters = () => ({ type: constants.REQUEST_CLUSTERS })

const requestClustersFailure = (error) => ({
  type: constants.REQUEST_CLUSTERS_FAILURE,
  error,
})

const receiveClusters = function (json, total) {
  // cache clusters in elektra
  backendAjaxClient.post("/cache/objects", {
    contentType: "application/json",
    dataType: "json",
    data: { objects: json, type: "kubernikus_cluster" },
  })

  return { type: constants.RECEIVE_CLUSTERS, clusters: json, total }
}

const loadClusters = () =>
  function (dispatch, getState) {
    const currentState = getState()
    const { clusters } = currentState
    const { isFetching } = clusters

    if (isFetching) {
      return
    } // don't fetch if we're already fetching
    dispatch(requestClusters())

    return ajaxHelper.get("/api/v1/clusters", {
      contentType: "application/json",
      success(data, textStatus, jqXHR) {
        return dispatch(receiveClusters(data))
      },
      error(jqXHR, textStatus, errorThrown) {
        const errorMessage =
          typeof jqXHR.responseJSON === "object"
            ? jqXHR.responseJSON.message
            : jqXHR.responseText.length > 0
            ? jqXHR.responseText
            : "The backend is currently slow to respond. Please try again later. We are on it."

        return dispatch(requestClustersFailure(errorMessage))
      },
    })
  }

const fetchClusters = () => (dispatch) => dispatch(loadClusters())

// ---- CLUSTER ----
const requestCluster = (clusterName) => ({
  type: constants.REQUEST_CLUSTER,
  clusterName,
})

const requestClusterFailure = (error) => ({
  type: constants.REQUEST_CLUSTER_FAILURE,
  error,
})

const receiveCluster = (cluster) => ({
  type: constants.RECEIVE_CLUSTER,
  cluster,
})

const startPollingCluster = (clusterName) => ({
  type: constants.START_POLLING_CLUSTER,
  clusterName,
})

const stopPollingCluster = (clusterName) => ({
  type: constants.STOP_POLLING_CLUSTER,
  clusterName,
})

const loadCluster = (clusterName) =>
  function (dispatch, getState) {
    // currentState    = getState()
    // cluster         = currentState.clusters
    // isFetching      = clusters.isFetching

    // return if isFetching # don't fetch if we're already fetching
    dispatch(requestCluster(clusterName))

    return ajaxHelper.get(`/api/v1/clusters/${clusterName}`, {
      contentType: "application/json",
      success(data, textStatus, jqXHR) {
        return dispatch(receiveCluster(data))
      },
      error(jqXHR, textStatus, errorThrown) {
        if (jqXHR == null) {
          dispatch(loadClusters()) // if no valid object is returned, just reload the whole list
        }
        switch (jqXHR.status) {
          case 404:
            return dispatch(loadClusters()) // if requested cluster not found reload the whole list to see what we have (the cluster was probably deleted)
          default:
            var errorMessage =
              typeof jqXHR.responseJSON === "object"
                ? jqXHR.responseJSON.message
                : jqXHR.responseText
            return dispatch(requestClusterFailure(errorMessage))
        }
      },
    })
  }

// -------------- CLUSTER EVENTS ---------------

const requestClusterEvents = (clusterName) => ({
  type: constants.REQUEST_CLUSTER_EVENTS,
  clusterName,
})

const requestClusterEventsFailure = (error) => ({
  type: constants.REQUEST_CLUSTER_EVENTS_FAILURE,
  error,
})

const receiveClusterEvents = (clusterName, events) => ({
  type: constants.RECEIVE_CLUSTER_EVENTS,
  clusterName,
  events,
})

const loadClusterEvents = (clusterName) =>
  function (dispatch, getState) {
    // return if isFetching # don't fetch if we're already fetching
    dispatch(requestClusterEvents(clusterName))

    return ajaxHelper.get(`/api/v1/clusters/${clusterName}/events`, {
      contentType: "application/json",
      success(data, textStatus, jqXHR) {
        return dispatch(receiveClusterEvents(clusterName, data))
      },
      error(jqXHR, textStatus, errorThrown) {
        const errorMessage =
          typeof jqXHR.responseJSON === "object"
            ? jqXHR.responseJSON.message
            : jqXHR.responseText
        return dispatch(requestClusterEventsFailure(errorMessage))
      },
    })
  }

// -------------- CREATE ---------------

const newClusterModal = () => ({
  type: ReactModal.SHOW_MODAL,
  modalType: "NEW_CLUSTER",
})

const openNewClusterDialog = () =>
  function (dispatch) {
    dispatch(loadMetaData())
    dispatch(loadInfo({ workflow: "new" }))
    dispatch(clusterFormForCreate())
    return dispatch(newClusterModal())
  }

const toggleAdvancedOptions = () => ({
  type: constants.FORM_TOGGLE_ADVANCED_OPTIONS,
})

// -------------- EDIT ---------------

const editClusterModal = () => ({
  type: ReactModal.SHOW_MODAL,
  modalType: "EDIT_CLUSTER",
})

const openEditClusterDialog = (cluster) =>
  function (dispatch) {
    dispatch(loadMetaData())
    dispatch(loadInfo({}))
    dispatch(clusterFormForUpdate(cluster))
    return dispatch(editClusterModal())
  }

// -------------- DELETE ---------------

const requestDeleteCluster = (clusterName) => (dispatch) =>
  dispatch(
    showConfirmDialog({
      title: "Delete Cluster",
      message: `Do you really want to delete cluster ${clusterName}?`,
      confirmCallback() {
        return dispatch(deleteCluster(clusterName))
      },
    })
  )

var deleteCluster = (clusterName) =>
  function (dispatch) {
    dispatch(deleteClusterConfirmed(clusterName))

    return ajaxHelper.delete(`/api/v1/clusters/${clusterName}`, {
      contentType: "application/json",
      success(data, textStatus, jqXHR) {
        return dispatch(fetchClusters())
      },
      error(jqXHR, textStatus, errorThrown) {
        const errorMessage =
          typeof jqXHR.responseJSON === "object"
            ? jqXHR.responseJSON.message
            : jqXHR.responseText
        return dispatch(deleteClusterFailure(clusterName, errorMessage))
      },
    })
  }

var deleteClusterConfirmed = () => ({ type: constants.DELETE_CLUSTER })

var deleteClusterFailure = (clusterName, error) => ({
  type: constants.DELETE_CLUSTER_FAILURE,
  error: `Couldn't delete cluster ${clusterName}: ${error}`,
})

// -------------- CREDENTIALS ---------------

const getCredentials = (clusterName) =>
  function (dispatch) {
    dispatch(requestCredentials(clusterName))

    return ajaxHelper.get(`/api/v1/clusters/${clusterName}/credentials`, {
      contentType: "application/json",
      success(data, textStatus, jqXHR) {
        return dispatch(receiveCredentials(clusterName, data))
      },
      error(jqXHR, textStatus, errorThrown) {
        return dispatch(
          requestCredentialsFailure(clusterName, jqXHR.responseText)
        )
      },
    })
  }

var requestCredentials = () => ({ type: constants.REQUEST_CREDENTIALS })

var requestCredentialsFailure = (clusterName, error) => ({
  type: constants.REQUEST_CREDENTIALS_FAILURE,
  flashError: `We couldn't retrieve the credentials for cluster ${clusterName} at this time. This might be because the cluster is not ready yet or is in an error state. Please try again.`,
})

var receiveCredentials = (clusterName, credentials) =>
  function (dispatch) {
    const blob = new Blob([credentials.kubeconfig], {
      type: "application/x-yaml;charset=utf-8",
    })
    return saveAs(blob, `${clusterName}-config`)
  }

// -------------- SETUP ---------------

const getSetupInfo = (clusterName, kubernikusBaseUrl) =>
  function (dispatch) {
    dispatch(requestSetupInfo(clusterName))

    return ajaxHelper.get(`/api/v1/clusters/${clusterName}/info`, {
      contentType: "application/json",
      success(data, textStatus, jqXHR) {
        return dispatch(receiveSetupInfo(clusterName, kubernikusBaseUrl, data))
      },
      error(jqXHR, textStatus, errorThrown) {
        return dispatch(
          requestSetupInfoFailure(clusterName, jqXHR.responseText)
        )
      },
    })
  }

var requestSetupInfo = () => ({ type: constants.REQUEST_SETUP_INFO })

var requestSetupInfoFailure = (clusterName, error) => ({
  type: constants.REQUEST_SETUP_INFO_FAILURE,
  flashError: `We couldn't retrieve the setup information for cluster ${clusterName} at this time. This might be because the cluster is not ready yet or is in an error state. Please try again.`,
})

var receiveSetupInfo = (clusterName, kubernikusBaseUrl, setupInfo) =>
  function (dispatch) {
    dispatch(dataForSetupInfo(setupInfo, kubernikusBaseUrl))
    return dispatch(setupInfoModal())
  }

var setupInfoModal = () => ({
  type: ReactModal.SHOW_MODAL,
  modalType: "SETUP_INFO",
})

var dataForSetupInfo = (data, kubernikusBaseUrl) => ({
  type: constants.SETUP_INFO_DATA,
  setupData: data,
  kubernikusBaseUrl,
})

//################ CLUSTER FORM ######################

var clusterFormForCreate = () => ({
  type: constants.PREPARE_CLUSTER_FORM,
  method: "post",
  action: "/api/v1/clusters",
})

const resetClusterForm = () => ({ type: constants.RESET_CLUSTER_FORM })

const closeClusterForm = () => (dispatch) => dispatch(resetClusterForm())

var clusterFormForUpdate = (cluster) => ({
  type: constants.PREPARE_CLUSTER_FORM,
  data: cluster,
  method: "put",
  action: `/api/v1/clusters/${cluster.name}`,
})

const clusterFormFailure = (errors) => ({
  type: constants.CLUSTER_FORM_FAILURE,
  errors,
})

const updateClusterForm = (name, value) => ({
  type: constants.UPDATE_CLUSTER_FORM,
  name,
  value,
})

const updateAdvancedOptions = (name, value) =>
  function (dispatch) {
    switch (name) {
      case "routerID":
        return dispatch(setDefaultsForRouter(value))
      case "networkID":
        return dispatch(setDefaultsForNetwork(value))
      default:
        return dispatch(updateAdvancedValue(name, value))
    }
  }

const changeVersion = (value) => ({
  type: constants.FORM_CHANGE_VERSION,
  value,
})

var setDefaultsForRouter = (value) =>
  function (dispatch, getState) {
    const { metaData } = getState()
    // going down the nested array rabbit hole
    const selectedRouterIndex = ReactHelpers.findIndexInArray(
      metaData.routers,
      value,
      "id"
    )
    const selectedRouter = metaData.routers[selectedRouterIndex]
    const defaultNetwork = selectedRouter.networks[0]
    const defaultSubnet = defaultNetwork.subnets[0]

    dispatch(updateAdvancedValue("routerID", value))
    dispatch(updateAdvancedValue("networkID", defaultNetwork.id))
    return dispatch(updateAdvancedValue("lbSubnetID", defaultSubnet.id))
  }

var setDefaultsForNetwork = (value) =>
  function (dispatch, getState) {
    const { metaData } = getState()
    // going down the nested array rabbit hole
    const selectedRouterIndex = ReactHelpers.findIndexInArray(
      metaData.routers,
      getState().clusterForm.data.spec.openstack.routerID,
      "id"
    )
    const selectedRouter = metaData.routers[selectedRouterIndex]
    const selectedNetworkIndex = ReactHelpers.findIndexInArray(
      selectedRouter.networks,
      value,
      "id"
    )
    const selectedNetwork = selectedRouter.networks[selectedNetworkIndex]
    const defaultSubnet = selectedNetwork.subnets[0]

    dispatch(updateAdvancedValue("networkID", value))
    return dispatch(updateAdvancedValue("lbSubnetID", defaultSubnet.id))
  }

var updateAdvancedValue = (name, value) => ({
  type: constants.FORM_UPDATE_ADVANCED_VALUE,
  name,
  value,
})

const updateSSHKey = (value) => ({
  type: constants.FORM_UPDATE_SSH_KEY,
  value,
})

const updateKeyPair = (value) =>
  function (dispatch) {
    dispatch(setKeyPair(value))
    const keyValue = value === "other" ? "" : value
    return dispatch(updateSSHKey(keyValue))
  }

var setKeyPair = (value) => ({
  type: constants.FORM_UPDATE_KEY_PAIR,
  value,
})

const updateNodePoolForm = (index, name, value) => ({
  type: constants.UPDATE_NODE_POOL_FORM,
  index,
  name,
  value,
})

const addNodePool = (defaultAZ) => ({
  type: constants.ADD_NODE_POOL,
  defaultAZ,
})

const deleteNodePool = (index) => ({
  type: constants.DELETE_NODE_POOL,
  index,
})

const submitClusterForm = (successCallback = null) =>
  function (dispatch, getState) {
    const { clusterForm } = getState()
    if (clusterForm.isValid) {
      dispatch({ type: constants.SUBMIT_CLUSTER_FORM })
      return ajaxHelper[clusterForm.method](clusterForm.action, {
        contentType: "application/json",
        data: clusterForm.data,

        success(data, textStatus, jqXHR) {
          dispatch(resetClusterForm())
          dispatch(receiveCluster(data))
          if (successCallback) {
            return successCallback()
          }
        },
        error(jqXHR, textStatus, errorThrown) {
          const errorMessage =
            typeof jqXHR.responseJSON === "object"
              ? jqXHR.responseJSON.message
              : jqXHR.responseText

          return dispatch(clusterFormFailure({ "Please Note": [errorMessage] }))
        },
      })
    }
  }

// export
export {
  fetchClusters,
  requestDeleteCluster,
  openNewClusterDialog,
  openEditClusterDialog,
  toggleAdvancedOptions,
  updateAdvancedOptions,
  changeVersion,
  updateSSHKey,
  updateKeyPair,
  loadCluster,
  loadClusterEvents,
  getCredentials,
  getSetupInfo,
  clusterFormForCreate,
  clusterFormForUpdate,
  submitClusterForm,
  closeClusterForm,
  updateClusterForm,
  updateNodePoolForm,
  addNodePool,
  deleteNodePool,
  startPollingCluster,
  stopPollingCluster,
}
