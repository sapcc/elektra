const initialState = {
  items: [],
  isFetching: false,
  error: null,
  loaded: false,
}

const sortByName = (a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0)

const requestSecrets = (secretsState) => {
  return { ...secretsState, isFetching: true, error: null }
}

const receiveSecrets = (secretsState, action) => {
  if (action.secrets) {
    return {
      ...secretsState,
      isFetching: false,
      error: null,
      items: action.secrets.sort(sortByName),
      loaded: true,
    }
  } else if (action.item) {
    const secrets = secretsState.items.slice()
    const index = secrets.findIndex(
      (i) => i.secret_ref.indexOf(action.item.id) >= 0
    )
    if (index >= 0) {
      secrets[index] = { ...secrets[index], ...action.item }
    } else {
      secrets.push(action.item)
    }
    return {
      ...secretsState,
      isFetching: false,
      error: null,
      items: secrets.sort(sortByName),
    }
  }
  return secretsState
}

const requestSecretsFailure = (secretsState, action) => {
  return { ...secretsState, isFetching: false, error: action.error }
}

const deleteSecrets = (secretsState, action) => {
  const index = secretsState.items.findIndex(
    (i) => i.secret_ref.indexOf(action.id) >= 0
  )
  if (index < 0) return secretsState
  const secrets = secretsState.items.slice()
  secrets.splice(index, 1)
  return { ...secretsState, items: secrets, error: null }
}

const requestDeleteSecrets = (secretsState, action) => {
  const index = secretsState.items.findIndex(
    (i) => i.secret_ref.indexOf(action.id) >= 0
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
