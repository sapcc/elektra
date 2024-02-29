const getUserToken = async () => {
  let path = "/os-api/__token"
  if (window.scopedProjectId) path = `${window.scopedProjectId}/${path}`
  if (window.scopedDomainId) path = `/${window.scopedDomainId}/${path}`

  return fetch(path)
    .then((response) => response.json())
    .then((token) => {
      const authToken = token.value
      delete token.value
      return {
        authToken,
        ...token,
      }
    })
}

window._getCurrentToken = window._getCurrentToken || getUserToken

// example
// window
//   ._getCurrentToken()
//   .then((token) => console.log("--------------------------", token))
