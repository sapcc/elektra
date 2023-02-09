const initialState = {
  items: [],
  isFetching: false,
  error: null,
  loaded: false,
  totalNumOfSecrets: 0,
}

const sortByCreationDate = (a, b) =>
  a.created > b.created ? -1 : a.created < b.created ? 1 : 0

const requestSecrets = (secretsState) => {
  return { ...secretsState, isFetching: true, error: null }
}

const updateSecrets = (secretsState, action) => {
  if (action.secrets) {
    return {
      ...secretsState,
      isFetching: false,
      error: null,
      items: action.secrets.sort(sortByCreationDate),
      loaded: true,
    }
  }
}

const receiveSecret = (secretsState, action) => {
  if (action.data) {
    const secrets = secretsState.items.slice()
    const index = secrets.findIndex(
      (i) => i.secret_ref.indexOf(action.data.secret_ref) >= 0
    )
    if (index >= 0) {
      secrets[index] = { ...secrets[index], ...action.data }
    } else {
      secrets.push(action.data)
      return {
        ...secretsState,
        // isFetching: false,
        // error: null,
        totalNumOfSecrets: secretsState.totalNumOfSecrets + 1,
        items: secrets.sort(sortByCreationDate),
      }
    }
    return {
      ...secretsState,
      // isFetching: false,
      // error: null,
      // totalNumOfSecrets: secretsState.totalNumOfSecrets + 1,
      items: secrets.sort(sortByCreationDate),
    }
  }
  return secretsState
}
const receiveSecretMetadata = (secretsState, action) => {
  debugger
  if (action.data) {
    const secrets = secretsState.items.slice()
    const index = secrets.findIndex(
      (i) => i.secret_ref.indexOf(action.data.secret_ref) >= 0
    )
    if (index >= 0) {
      secrets[index] = { ...secrets[index], ...action.data }
    } else {
      secrets.push(action.data)
      return {
        ...secretsState,
        // isFetching: false,
        // error: null,
        totalNumOfSecrets: secretsState.totalNumOfSecrets + 1,
        items: secrets.sort(sortByCreationDate),
      }
    }
    return {
      ...secretsState,
      // isFetching: false,
      // error: null,
      // totalNumOfSecrets: secretsState.totalNumOfSecrets + 1,
      items: secrets.sort(sortByCreationDate),
    }
  }
  return secretsState
}

const receiveSecrets = (secretsState, action) => {
  console.log("receiveSecrets: ", action)
  if (!action.secrets) return secretsState
  return {
    ...secretsState,
    isFetching: false,
    error: null,
    items: action.secrets.sort(sortByCreationDate),
    totalNumOfSecrets: action.totalNumOfSecrets,
    loaded: true,
  }
}

const requestSecretsFailure = (secretsState, action) => {
  return { ...secretsState, isFetching: false, error: action.error }
}

const requestSecretFailure = (secretsState, action) => {
  return { ...secretsState, isFetching: false, error: action.error }
}

const deleteSecrets = (secretsState, action) => {
  const index = secretsState.items.findIndex(
    (i) => i.secret_ref.indexOf(action.secretUuid) >= 0
  )
  if (index < 0) return secretsState
  const secrets = secretsState.items.slice()
  secrets.splice(index, 1)

  return {
    ...secretsState,
    items: secrets,
    totalNumOfSecrets: secretsState.totalNumOfSecrets - 1,
    error: null,
  }
}

const requestDeleteSecrets = (secretsState, action) => {
  const index = secretsState.items.findIndex(
    (i) => i.secret_ref.indexOf(action.secretUuid) >= 0
  )
  if (index < 0) return secretsState
  const secrets = secretsState.items.slice()
  secrets[index] = { ...secrets[index], isDeleting: true }
  return { ...secretsState, items: secrets }
}

const deleteSecretsFailure = (secretsState, action) => {
  const index = secretsState.items.findIndex(
    (i) => i.secret_ref.indexOf(action.id) >= 0
  )
  if (index < 0) return secretsState
  const secrets = secretsState.items.slice()
  secrets[index] = { ...secrets[index], isDeleting: false }
  return { ...secretsState, items: secrets, error: action.error }
}

export default (secretsState = initialState, action) => {
  switch (action.type) {
    case "REQUEST_SECRETS":
      return requestSecrets(secretsState)
    case "RECEIVE_SECRETS":
      return receiveSecrets(secretsState, action)
    case "RECEIVE_SECRET":
      return receiveSecret(secretsState, action)
    case "RECEIVE_SECRET_Metadata":
      return receiveSecretMetadata(secretsState, action)
    case "UPDATE_SECRET":
      return updateSecrets(secretsState, action)
    case "REQUEST_SECRETS_FAILURE":
      return requestSecretsFailure(secretsState, action)
    case "DELETE_SECRETS":
      return deleteSecrets(secretsState, action)
    case "REQUEST_DELETE_SECRETS":
      return requestDeleteSecrets(secretsState, action)
    case "DELETE_SECRETS_FAILURE":
      return deleteSecretsFailure(secretsState, action)
    default:
      return secretsState
  }
}
