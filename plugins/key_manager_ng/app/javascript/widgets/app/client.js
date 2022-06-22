const checkStatus = (response) => {
  if (response.status >= 200 && response.status < 300) {
    return response
  } else {
    return response.text().then((message) => {
      var error = new Error(message || response.statusText || response.status)
      error.statusCode = response.status
      // throw error
      return Promise.reject(error)
    })
  }
}

let defaultHeaders = { "Content-Type": "application/json" }
// search for csrf token in meta tags.
const metaTags = [].slice.call(document.getElementsByTagName("meta"))
const csrfToken = metaTags.find(
  (tag) => tag.getAttribute("name") == "csrf-token"
)
if (csrfToken)
  defaultHeaders["x-csrf-token"] = csrfToken.getAttribute("content")

export const get = (url) =>
  fetch(url, { headers: defaultHeaders })
    .then(checkStatus)
    .then((response) => response.json())

export const del = (url) => {
  return fetch(url, {
    headers: defaultHeaders,
    method: "DELETE",
  }).then(checkStatus)
}

export const post = (url, values) => {
  return fetch(url, {
    headers: defaultHeaders,
    method: "POST",
    body: JSON.stringify(values),
  })
    .then(checkStatus)
    .then((response) => response.json())
}

export const patch = (url, values) => {
  return fetch(url, {
    headers: defaultHeaders,
    method: "PATCH",
    body: JSON.stringify(values),
  })
    .then(checkStatus)
    .then((response) => response.json())
}

export const put = (url, values) => {
  return fetch(url, {
    headers: defaultHeaders,
    method: "PUT",
    body: JSON.stringify(values),
  })
    .then(checkStatus)
    .then((response) => response.json())
}
