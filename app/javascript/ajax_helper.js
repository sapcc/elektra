import { mergeDeep } from "./lib/tools/deep_merge"
import axios from "axios"

// containers for global options and scope
let globalOptions = {}
export let scope = {}

// this variables are needed by integration tests
window.activeAjaxCallsCount = 0
window.failedAjaxCallsCount = 0

// find scope and store it in the scope variable
const foundScope = window.location.pathname.match(/\/([^\/]+)\/([^\/|\?|&]+)/i)
if (foundScope) {
  scope = { domain: foundScope[1], project: foundScope[2] }
}

export let ajaxHelper

// configure and create the default ajax client
export const configureAjaxHelper = (options) => {
  // store options in globalOptions
  if (options) globalOptions = options
  ajaxHelper = createAjaxHelper()
}

// this method creates a special ajax client for a given plugin name
export const pluginAjaxHelper = (pluginName, options = {}) => {
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

// creates and returns a new instance of axios.
// an options parameter can be provided to overwrite config
// parameters like headers or baseURL
export const createAjaxHelper = (options = {}) => {
  const instanceOptions = Object.assign({ timeout: 60000 }, options)
  // create a copy of options headers
  instanceOptions.headers = Object.assign({}, options.headers)

  if (
    !instanceOptions.headers["X-Auth-Token"] &&
    !instanceOptions.headers["x-auth-token"]
  ) {
    // search for csrf token in meta tags.
    const metaTags = [].slice.call(document.getElementsByTagName("meta"))
    const csrfToken = metaTags.find(
      (tag) => tag.getAttribute("name") == "csrf-token"
    )
    if (csrfToken)
      instanceOptions.headers["x-csrf-token"] =
        csrfToken.getAttribute("content")
  }

  // console.log('instanceOptions',instanceOptions)
  const axiosInstance = axios.create(instanceOptions)
  // overwrite default Accept Header to use json only

  // no reason to devide the header on this place. Designate is the one service which needs
  // the Accept-Charset Header. But Elektra speaks to designate via elektron and not via CORS.
  // So, not needed yet here!!!
  // axiosInstance.defaults.headers.common['Accept'] = 'application/json';
  // axiosInstance.defaults.headers.common['Accept-Charset'] = 'utf-8';

  axiosInstance.defaults.headers.common["Accept"] =
    "application/json; charset=utf-8"

  // use request interceptor to merge globalOptions.
  // The global options are available only after the entire JS
  // suite has been loaded. So we cannot merge it earlier :(
  axiosInstance.interceptors.request.use(
    function (config) {
      // increase active ajax calls counter
      window.activeAjaxCallsCount += 1

      // console.log('globalOptions',JSON.stringify(globalOptions))
      let newConfig = mergeDeep(
        JSON.parse(JSON.stringify(globalOptions)),
        config
      )
      // remove x-csrf-token if x-auth-token is presented
      if (
        newConfig.headers["X-Auth-Token"] ||
        newConfig.headers["x-auth-token"]
      ) {
        delete newConfig.headers["x-csrf-token"]
      }
      // console.log('config',config)
      // console.log('newConfig',newConfig)
      return newConfig
    },
    function (error) {
      // Do something with response error
      return Promise.reject(error)
    }
  )

  // Add a response interceptor
  axiosInstance.interceptors.response.use(
    function (response) {
      // decrease the active ajax calls counter
      window.activeAjaxCallsCount -= 1
      // Check if location exists in the response headers
      if (response && response.headers && response.headers.location) {
        // location is presented -> build the redirect url
        let currentUrl = encodeURIComponent(window.location.href)
        // console.log('currentUrl',currentUrl)

        let redirectToUrl = response.headers.location

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
        throw new Error(
          "Your session has expired. You will be redirected to the login page!"
        )
      }
      return response
    },
    function (error) {
      // also in error case we should decrease the active ajax calls counter
      window.activeAjaxCallsCount -= 1
      // increase the failed counter
      window.failedAjaxCallsCount += 1
      // Do something with response error
      return Promise.reject(error)
    }
  )

  return axiosInstance
}
