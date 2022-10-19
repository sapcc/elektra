const ALLOWED_CLIENT_CONFIG_KEYS = [
  "baseURL",
  "headers",
  "pathPrefix",
  "headerPrefix",
  "nonPrefixHeaders",
  "params",
  "timeout",
  "debug",
]

const DEFAULT_HEADERS = {
  // "Content-Type": "application/json",
  Accept: "application/json; charset=utf-8",
  "X-Requested-With": "XMLHttpRequest",
}
const OS_API_PATH_PREFIX = "os-api"
const OS_API_HEADER_PREFIX = "OS-API-"
const X_CSRF_TOKEN_KEY = "x-csrf-token"
let X_CSRF_TOKEN_VALUE

// search for csrf token in meta tags.
const metaTags = [].slice.call(document.getElementsByTagName("meta"))
const csrfToken = metaTags.find((t) => t.getAttribute("name") == "csrf-token")
if (csrfToken) X_CSRF_TOKEN_VALUE = csrfToken.getAttribute("content")

const scope = {
  domain: window.scopedDomainFid,
  project: window.scopedProjectFid,
}
if (!scope.domain) {
  // find scope and store it in the scope variable
  const foundScope = window.location.pathname.match(/\/([^/]+)\/([^/|?|&]+)/i)
  if (foundScope) {
    scope.domain = foundScope[1]
    scope.project = foundScope[2]
  }
}

const toPath = (pathParts = [], params = {}) => {
  // filter out undefined and empty path parts
  const filteredPath = pathParts.filter((p) => p && p !== "")
  //if (filteredPath.length === 1) return filteredPath[0]
  // replace all double slashes with one slash except http(s)://
  let path = filteredPath.join("/").replace(/([^:])(\/{2,})/g, "$1/")
  let query =
    params && typeof params === "object"
      ? Object.keys(params)
          .filter((k) => !!params[k])
          .map(
            (k) => `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`
          )
          .join("&")
      : ""
  if (query && query !== "") path += "?" + query
  return path
}

const checkClientConfig = (config = {}) => {
  const badConfigKeys = Object.keys(config).filter(
    (key) => !ALLOWED_CLIENT_CONFIG_KEYS.includes(key)
  )
  if (badConfigKeys.length > 0)
    throw new Error(`Config keys ${badConfigKeys.join(", ")} are not allowed`)
}

const handleResponse = async (response) => {
  // we have to convert fetch headers object to hash map
  // to ensure (axios) backwards compatibility.
  // Important: the Headers object from fetch makes all keys lower case.
  const headers = {}
  if (response.headers)
    response.headers.forEach((value, key) => (headers[key] = value))

  // handle location header (redirect to login)
  if (headers && headers.location) {
    // location is presented -> build the redirect url
    let currentUrl = encodeURIComponent(window.location.href)
    // console.log('currentUrl',currentUrl)

    let redirectToUrl = headers.location

    if (redirectToUrl.match(/after_login=(.*)/i)) {
      redirectToUrl = redirectToUrl.replace(
        /after_login=(.*)/g,
        `after_login=${currentUrl}`
      )
    } else if (redirectToUrl.match(/\/auth\/login/i)) {
      redirectToUrl = `${redirectToUrl}?after_login=${currentUrl}`
    }

    // redirect and throw an error. This error will be catched by
    // Promisse catch block in each request.
    if (currentUrl != redirectToUrl) window.location.replace(redirectToUrl)
  }

  // Important: the Headers object from fetch makes all keys lower case.
  const ResponseContentType = headers["content-type"] || ""

  // we try to convert data to json if content-type is application/json
  let data =
    ResponseContentType.indexOf("application/json") >= 0
      ? await response.json().catch((e) => e)
      : null

  if (!response.ok) {
    const error = new Error(response.statusText || response.status)

    error.status = response.status
    error.headers = headers
    // data is set if response is a json. Otherwise it is null
    // to ensure (axios) backwards compatibility
    error.data = data
    // store origin fetch response
    // it allows us to call other functions like blob() or text()
    error.response = response

    throw error
  }

  return {
    data,
    response: response,
    headers,
    status: response.status,
  }
}

const mergeConfigs = (...configs) => {
  let config = {}
  for (let config2 of configs) {
    config = {
      ...config,
      ...config2,
      headers: { ...config?.headers, ...config2?.headers },
      nonPrefixHeaders: {
        ...config?.nonPrefixHeaders,
        ...config2?.nonPrefixHeaders,
      },
      params: { ...config?.params, ...config2?.params },
    }
  }

  return config
}

const prepareRequest = (path, config = {}) => {
  // merge and remove non fetch options
  let {
    baseURL,
    pathPrefix,
    headerPrefix,
    nonPrefixHeaders,
    params,
    timeout,
    headers,
    body,
    debug,
    ...otherOptions
  } = config

  // try to convert body to json until it is a file, form data or string
  if (
    body &&
    typeof body !== "string" &&
    !(body instanceof FormData) &&
    !(body instanceof File)
  ) {
    try {
      body = JSON.stringify(body)
      headers["Content-Type"] = headers["Content-Type"] || "application/json"
    } catch (e) {}
  }

  // add header prefix to all keys if presented
  if (headerPrefix && headers) {
    for (let key in headers) {
      headers[`${headerPrefix}${key}`] = headers[key]
      delete headers[key]
    }
  }

  headers = { ...DEFAULT_HEADERS, ...headers, ...nonPrefixHeaders }
  // remove csrf token if x-auth token is presented
  if (!headers["X-Auth-Token"] && !headers["x-auth-token"])
    headers[X_CSRF_TOKEN_KEY] = X_CSRF_TOKEN_VALUE

  // final path
  const url = toPath([baseURL, pathPrefix, path], params)

  if (debug)
    console.log("url: ", url, "options: ", { headers, body, ...otherOptions })

  // create cancel controller
  const controller = new AbortController()
  // set timer for cancellation if timeout is set
  const timer = timeout && setTimeout(() => controller.abort(), timeout * 1000)

  const request = window
    .fetch(url, {
      headers,
      body,
      redirect: "follow",
      referrerPolicy: "no-referrer",
      ...otherOptions,
      signal: controller.signal,
    })
    .then((response) => {
      if (timer) clearTimeout(timer)
      return handleResponse(response)
    })

  return { request, cancel: controller.abort }
}

/**
 *
 * @param {object} config contains baseURL and headers
 * @returns object with get,head,put,patch,post,copy,delete, osApi
 */
const Client = (config = {}) => {
  checkClientConfig(config)

  // For backward compatibility, the http methods are offered directly.
  // However, it makes sense to offer the cancel function for asynchronous requests.
  // Therefore, under cancelable, there are the http methods again, which not only return
  // the request, but also the cancel function.

  // The following options are available:
  //   client.get("PATH",options) -> request
  // and
  //   client.cancelable.get("PATH",options) -> {request, cancel}
  return {
    cancelable: {
      head: (path, options = {}) =>
        prepareRequest(
          path,
          mergeConfigs(config, options, {
            method: "HEAD",
          })
        ),
      get: (path, options = {}) =>
        prepareRequest(path, mergeConfigs(config, options, { method: "GET" })),
      put: (path, values = {}, options = {}) =>
        prepareRequest(
          path,
          mergeConfigs(config, options, { method: "PUT", body: values })
        ),
      post: (path, values = {}, options = {}) =>
        prepareRequest(
          path,
          mergeConfigs(config, options, { method: "POST", body: values })
        ),
      patch: (path, values = {}, options = {}) =>
        prepareRequest(
          path,
          mergeConfigs(config, options, { method: "PATCH", body: values })
        ),
      copy: (path, options) =>
        prepareRequest(path, mergeConfigs(config, options, { method: "COPY" })),
      delete: (path, options = {}) =>
        prepareRequest(
          path,
          mergeConfigs(config, options, { method: "DELETE" })
        ),
    },
    head: (path, options = {}) =>
      prepareRequest(
        path,
        mergeConfigs(config, options, {
          method: "HEAD",
        })
      ).request,
    get: (path, options = {}) =>
      prepareRequest(path, mergeConfigs(config, options, { method: "GET" }))
        .request,
    put: (path, values = {}, options = {}) =>
      prepareRequest(
        path,
        mergeConfigs(config, options, { method: "PUT", body: values })
      ).request,
    post: (path, values = {}, options = {}) =>
      prepareRequest(
        path,
        mergeConfigs(config, options, { method: "POST", body: values })
      ).request,
    patch: (path, values = {}, options = {}) =>
      prepareRequest(
        path,
        mergeConfigs(config, options, { method: "PATCH", body: values })
      ).request,
    copy: (path, options) =>
      prepareRequest(path, mergeConfigs(config, options, { method: "COPY" }))
        .request,
    delete: (path, options = {}) =>
      prepareRequest(path, mergeConfigs(config, options, { method: "DELETE" }))
        .request,
  }
}

let ajaxHelper

// configure and create the default ajax client
const configureAjaxHelper = (options = {}) => {
  // store options in globalOptions
  if (options) ajaxHelper = createAjaxHelper(options)
  return ajaxHelper
}

// this method creates a special ajax client for a given plugin name
const pluginAjaxHelper = (pluginName, options = {}) => {
  // console.log('pluginAjaxHelper options before',options,scope)

  if (!options.baseURL) {
    const domain =
      options.domain == false ? null : options.domain || scope.domain
    let project =
      options.project == false ? null : options.project || scope.project
    if (project == "cc-tools") project = null

    delete options.domain
    delete options.project

    if (domain) options.baseURL = `/${domain}`
    if (options.baseURL && project) options.baseURL += `/${project}`

    if (pluginName) {
      if (options.baseURL) options.baseURL += `/${pluginName}`
      else options.baseURL = pluginName
    }
    if (options.baseURL) options.baseURL += "/"
  }

  return createAjaxHelper(options)
}

const createAjaxHelper = (options = {}) => {
  return {
    ...Client(options),

    osApi: (serviceName, osApiOptions = {}) => {
      const newOsApiOptions = { ...osApiOptions }
      // add header prefix for all headers keys
      if (newOsApiOptions.headers) {
        for (let key in newOsApiOptions.heders) {
          newOsApiOptions[`${OS_API_HEADER_PREFIX}${key}`] =
            newOsApiOptions.headers[key]
          delete newOsApiOptions.headers[key]
        }
      }

      let mergedOptions = {
        pathPrefix: "",
        headerPrefix: "",
        ...options,
        ...newOsApiOptions,
      }
      mergedOptions.pathPrefix = toPath([
        OS_API_PATH_PREFIX,
        serviceName,
        mergedOptions.pathPrefix,
      ])
      mergedOptions.headerPrefix =
        OS_API_HEADER_PREFIX + mergedOptions.headerPrefix
      return Client(mergedOptions)
    },
  }
}

export {
  scope,
  ajaxHelper,
  pluginAjaxHelper,
  configureAjaxHelper,
  createAjaxHelper,
}
