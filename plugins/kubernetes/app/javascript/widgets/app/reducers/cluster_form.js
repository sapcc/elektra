/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import ReactHelpers from "../lib/helpers"
import * as constants from "../constants"
//######################### CLUSTER FORM ###########################
// TODO: remove hardcoded flavor selection
const initialClusterFormState = {
  method: "post",
  action: "",
  data: {
    name: "",
    spec: {
      nodePools: [
        {
          flavor: "m1.small",
          image: "",
          name: "",
          size: "",
          availabilityZone: "",
          new: true,
          config: {
            allowReboot: true,
            allowReplace: true,
          },
        },
      ],
      openstack: {},
      sshPublicKey: "",
      keyPair: "",
      version: null,
    },
    status: {
      nodePools: [],
    },
  },
  isSubmitting: false,
  errors: null,
  isValid: false,
  nodePoolsValid: false,
  advancedOptionsValid: true,
  updatePending: false,
  advancedOptionsVisible: false,
}

const resetClusterForm = function (state, ...rest) {
  const obj = rest[0]
  return initialClusterFormState
}

const updateClusterForm = function (state, { name, value }) {
  const data = ReactHelpers.mergeObjects({}, state.data, { [name]: value })
  return ReactHelpers.mergeObjects({}, state, {
    data,
    errors: null,
    isSubmitting: false,
    updatePending: true,
    isValid:
      data.name.length > 0 &&
      state.nodePoolsValid &&
      state.advancedOptionsValid,
  })
}

const updateAdvancedValue = function (state, { name, value }) {
  const dataClone = JSON.parse(JSON.stringify(state.data))
  dataClone.spec.openstack[name] = value
  return ReactHelpers.mergeObjects({}, state, {
    data: dataClone,
    updatePending: true,
  })
}

const changeVersion = function (state, { value }) {
  const dataClone = JSON.parse(JSON.stringify(state.data))
  dataClone.spec.version = value
  return ReactHelpers.mergeObjects({}, state, {
    data: dataClone,
    updatePending: true,
  })
}

const updateSSHKey = function (state, { value }) {
  const dataClone = JSON.parse(JSON.stringify(state.data))
  dataClone.spec.sshPublicKey = value
  return ReactHelpers.mergeObjects({}, state, {
    data: dataClone,
    updatePending: true,
  })
}

const updateKeyPair = function (state, { value }) {
  const dataClone = JSON.parse(JSON.stringify(state.data))
  dataClone.spec.keyPair = value
  return ReactHelpers.mergeObjects({}, state, {
    data: dataClone,
    updatePending: true,
  })
}

const updateNodePoolForm = function (state, { index, name, value }) {
  const nodePool = (() => {
    if (/allowReboot|allowReplace/.test(name)) {
      const configClone = JSON.parse(
        JSON.stringify(state.data.spec.nodePools[index].config)
      )
      configClone[name] = value
      return ReactHelpers.mergeObjects({}, state.data.spec.nodePools[index], {
        config: configClone,
      })
    } else {
      return ReactHelpers.mergeObjects({}, state.data.spec.nodePools[index], {
        [name]: value,
      })
    }
  })()

  const nodePoolsClone = state.data.spec.nodePools.slice(0)
  if (index >= 0) {
    nodePoolsClone[index] = nodePool
  } else {
    nodePoolsClone.push(nodePool)
  }
  const stateClone = JSON.parse(JSON.stringify(state))
  stateClone.data.spec.nodePools = nodePoolsClone
  const poolValidity =
    nodePool.name.length > 0 &&
    nodePool.size >= 0 &&
    nodePool.flavor.length > 0 &&
    nodePool.availabilityZone.length > 0

  return ReactHelpers.mergeObjects(state, stateClone, {
    nodePoolsValid: poolValidity,
    isValid:
      state.data.name.length > 0 && poolValidity && state.advancedOptionsValid,
    updatePending: true,
  })
}

const addNodePool = function (state, { defaultAZ }) {
  // TODO: remove hardcoded flavor selection
  const newPool = {
    flavor: "m1.small",
    image: "",
    name: "",
    size: "",
    availabilityZone: defaultAZ,
    config: {
      allowReboot: true,
      allowReplace: true,
    },
    new: true,
  }

  const nodePoolsClone = state.data.spec.nodePools.slice(0)
  nodePoolsClone.push(newPool)
  const stateClone = JSON.parse(JSON.stringify(state))
  stateClone.data.spec.nodePools = nodePoolsClone
  stateClone.updatePending = true
  stateClone.isValid = false
  stateClone.nodePoolsValid = false
  return ReactHelpers.mergeObjects({}, state, stateClone)
}

const deleteNodePool = function (state, { index }) {
  // remove pool with given index
  const deletedPool = state.data.spec.nodePools[index]
  const updateNeeded = deletedPool.new ? false : true
  const nodePoolsFiltered = state.data.spec.nodePools.filter(
    (pool) => pool !== deletedPool
  )
  const stateClone = JSON.parse(JSON.stringify(state))
  stateClone.data.spec.nodePools = nodePoolsFiltered
  stateClone.updatePending = updateNeeded
  return ReactHelpers.mergeObjects({}, state, stateClone)
}

const submitClusterForm = function (state, ...rest) {
  const obj = rest[0]
  return ReactHelpers.mergeObjects({}, state, {
    isSubmitting: true,
    errors: null,
  })
}

const prepareClusterForm = function (state, { action, method, data }) {
  const values = {
    method,
    action,
    errors: null,
  }
  if (data) {
    values["data"] = data
  }
  // deep copy spec
  if (data) {
    values.data.spec = ReactHelpers.mergeObjects(
      {},
      initialClusterFormState.data.spec,
      data.spec
    )
  }

  // validity check
  if (data) {
    let nodePoolsValid = true
    for (var nodePool of Array.from(data.spec.nodePools)) {
      if (
        !(nodePool.name.length > 0) ||
        !(nodePool.size >= 0) ||
        !(nodePool.flavor.length > 0) ||
        !nodePool.availabilityZone ||
        !(nodePool.availabilityZone.length > 0)
      ) {
        nodePoolsValid = false
      }
    }

    values["isValid"] =
      data.name.length > 0 && nodePoolsValid && state.advancedOptionsValid
  }

  return ReactHelpers.mergeObjects({}, initialClusterFormState, values)
}

const clusterFormFailure = (state, { errors }) =>
  ReactHelpers.mergeObjects({}, state, {
    isSubmitting: false,
    errors,
  })

const toggleAdvancedOptions = function (state) {
  const optionsVisible = state.advancedOptionsVisible
  return ReactHelpers.mergeObjects({}, state, {
    advancedOptionsVisible: !optionsVisible,
  })
}

const setClusterFormDefaultVersion = function (state, { info }) {
  const stateClone = JSON.parse(JSON.stringify(state))
  stateClone.data.spec.version = info.defaultClusterVersion
  return ReactHelpers.mergeObjects({}, state, stateClone)
}

const setClusterFormDefaults = function (state, { metaData }) {
  // set default values in cluster form
  const defaults = {}
  // router -> network -> subnet chain
  if (metaData.routers != null) {
    const router = metaData.routers[0]
    defaults.routerID = router != null ? router.id : ""

    if (router.networks != null) {
      const network = router.networks[0]
      defaults.networkID = network != null ? network.id : ""

      if (network.subnets != null) {
        defaults.lbSubnetID =
          network.subnets[0] != null ? network.subnets[0].id : ""
      }
    }
  }

  // securityGroups
  if (metaData.securityGroups != null) {
    defaults.securityGroupName = metaData.securityGroups[0]
      ? metaData.securityGroups[0].name
      : ""
  }

  // ensure already selected values aren't overwritten by the defaults
  const dataMerged = ReactHelpers.mergeObjects(
    {},
    defaults,
    state.data.spec.openstack
  )

  // keyPair
  let keyPair = ""
  if (metaData.keyPairs != null) {
    const { sshPublicKey } = state.data.spec
    if (sshPublicKey != null && sshPublicKey.length > 0) {
      const index = ReactHelpers.findIndexInArray(
        metaData.keyPairs,
        sshPublicKey,
        "publicKey"
      )
      if (index >= 0) {
        // in this case the key belongs to a key pair
        keyPair = sshPublicKey
      } else {
        // in this case the key is a key that can't be found in the user's key pairs
        keyPair = "other"
      }
    }
  }

  // nodepools set default AZ
  let nodePoolsClone = []
  if (metaData.availabilityZones != null) {
    const defaultAZName = metaData.availabilityZones[0].name
    nodePoolsClone = state.data.spec.nodePools
    for (var pool of Array.from(nodePoolsClone)) {
      if (!pool.availabilityZone || !(pool.availabilityZone.length > 0)) {
        pool.availabilityZone = defaultAZName
      }
    }
  }

  const stateClone = JSON.parse(JSON.stringify(state))
  stateClone.data.spec.openstack = dataMerged
  stateClone.data.spec.keyPair = keyPair
  stateClone.data.spec.nodePools = nodePoolsClone
  return ReactHelpers.mergeObjects({}, state, stateClone)
}

const clusterForm = function (state, action) {
  if (state == null) {
    state = initialClusterFormState
  }
  switch (action.type) {
    case constants.RESET_CLUSTER_FORM:
      return resetClusterForm(state, action)
    case constants.UPDATE_CLUSTER_FORM:
      return updateClusterForm(state, action)
    case constants.UPDATE_NODE_POOL_FORM:
      return updateNodePoolForm(state, action)
    case constants.ADD_NODE_POOL:
      return addNodePool(state, action)
    case constants.DELETE_NODE_POOL:
      return deleteNodePool(state, action)
    case constants.SUBMIT_CLUSTER_FORM:
      return submitClusterForm(state, action)
    case constants.PREPARE_CLUSTER_FORM:
      return prepareClusterForm(state, action)
    case constants.CLUSTER_FORM_FAILURE:
      return clusterFormFailure(state, action)
    case constants.FORM_TOGGLE_ADVANCED_OPTIONS:
      return toggleAdvancedOptions(state, action)
    case constants.FORM_UPDATE_ADVANCED_VALUE:
      return updateAdvancedValue(state, action)
    case constants.FORM_CHANGE_VERSION:
      return changeVersion(state, action)
    case constants.FORM_UPDATE_SSH_KEY:
      return updateSSHKey(state, action)
    case constants.FORM_UPDATE_KEY_PAIR:
      return updateKeyPair(state, action)
    case constants.SET_CLUSTER_FORM_DEFAULTS:
      return setClusterFormDefaults(state, action)
    case constants.SET_CLUSTER_FORM_DEFAULT_VERSION:
      return setClusterFormDefaultVersion(state, action)
    default:
      return state
  }
}

export default clusterForm
