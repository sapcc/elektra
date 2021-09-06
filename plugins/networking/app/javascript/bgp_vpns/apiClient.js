// search for csrf token in meta tags.
const metaTags = [].slice.call(document.getElementsByTagName("meta"))
const csrfTokenTag = metaTags.find(
  (tag) => tag.getAttribute("name") == "csrf-token"
)
const csrfToken = csrfTokenTag && csrfTokenTag.getAttribute("content")

const pathParamsToUrl = (path, params) => {
  let url = path || ""
  if (!params || Object.keys(params).length === 0) return url

  url = new URL(
    window.location.protocol +
      "//" +
      window.location.host +
      window.location.pathname +
      path
  )
  Object.keys(params).forEach((key) =>
    url.searchParams.append(key, params[key])
  )

  return url
}

// Check response status
const checkStatus = (response) => {
  if (response.status >= 200 && response.status < 300) {
    return response
  } else {
    var error = new Error(response.statusText || response.status)
    error.response = response
    throw error
  }
}

export const get = (path, params = {}) => {
  let url = pathParamsToUrl(path, params)

  return fetch(url, {
    headers: { Accept: "application/json", "Content-Type": "application/json" },
  })
    .then(checkStatus)
    .then((response) => response.json())
}

export const post = (url, params = {}) =>
  fetch(url, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "x-csrf-token": csrfToken,
    },
    body: JSON.stringify(params),
  })
    .then(checkStatus)
    .then((response) => response.json())

export const del = (path, params = {}) => {
  let url = pathParamsToUrl(path, params)

  return fetch(url, {
    method: "DELETE",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "x-csrf-token": csrfToken,
    },
  }).then(checkStatus)
}

export const put = (url, params = {}) =>
  fetch(url, {
    method: "PUT",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "x-csrf-token": csrfToken,
    },
    body: JSON.stringify(params),
  })
    .then(checkStatus)
    .then((response) => response.json())
