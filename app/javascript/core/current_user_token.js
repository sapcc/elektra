const getUserToken = async () => {
  return fetch("os-api/__token")
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
