import axios from 'axios';
import { mergeDeep } from 'lib/tools/deep_merge'

let globalOptions = {headers: {}}

// scope
export let scope;

// get current scope
const foundScope = window.location.href.match(/[^\:]+\:\/\/[^\/]+\/([^\/]+)\/([^\/]+)/i)
if (foundScope) {
  scope = { domain: foundScope[1], project: foundScope[2] }
}

// global ajax helper
export let ajaxHelper;

// set global options and creat global ajax helper
export const configureAjaxHelper = (options) => {
  // store options in globalOptions
  if (options) globalOptions = options
  // create the default ajax helper. This helper is globaly available.
  ajaxHelper = createAjaxHelper()
}

// plugin scoped ajax helper. It is not global available!
export const pluginAjaxHelper = (pluginName, options) => {
  options = options || {}
  options.baseURL = options.baseURL || `/${scope.domain}/${scope.project}/${pluginName}`.replace(/\/\//,'/')
  return createAjaxHelper(options)
}

// creates a new axios instance using global and given options
export const createAjaxHelper = (options) => {
  options = options || {}
  options.headers = options.headers || {}

  // get current url without params and bind it to baseURL
  let origin = window.location.origin
  if(!origin) {
    const originMatch = window.location.href.match(/(http(s)?:\/\/[^\/]+).*/)
    if (originMatch) origin = originMatch[1]
  }
  let baseURL = options.baseURL || `${origin}${window.location.pathname}`;

  // extend baseURL with a slash unless last char is a slash
  if(baseURL.substr(-1) != '/') baseURL = baseURL+'/';


  // search for csrf token in meta tags.
  const metaTags = document.getElementsByTagName('meta');
  let csrfToken;
  for(let tag of metaTags) {
    if(tag.getAttribute('name') == 'csrf-token') {
      csrfToken = tag.getAttribute("content");
      break;
    }
  }

  // build headers
  let headers = {}

  // add csrfToken only if there is not x-auth-token provided.
  if (csrfToken && !options.headers['X-Auth-Token'] && !options.headers['x-auth-token']) {
    Object.assign(headers,{'x-csrf-token': csrfToken})
  }

  if (options.headers) Object.assign(headers, options.headers)

  // setup ajaxHelper
  const axiosInstance = axios.create({
    baseURL,
    timeout: 60000,
    headers
  })

  // overwrite default Accept Header to use json only
  axiosInstance.defaults.headers.common['Accept'] = 'application/json; charset=utf-8';

  // Add a request interceptor
  axiosInstance.interceptors.request.use(function (config) {
    // intercept before every request and merge global options with
    // the request options.
    config = mergeDeep(Object.assign({},globalOptions), config)
    return config;
  }, function (error) {
    // Do something with request error
    return Promise.reject(error);
  });

  // Add a response interceptor
  axiosInstance.interceptors.response.use(function (response) {
    // Check if location exists in the response headers
    if (response && response.headers && response.headers.location) {
      // location is presented -> build the redirect url
      let currentUrl = encodeURIComponent(window.location.href)
      // console.log('currentUrl',currentUrl)

      let redirectToUrl = response.headers.location

      if(redirectToUrl.match(/after_login=(.*)/i)) {
        redirectToUrl = redirectToUrl.replace(
          /after_login=(.*)/g, `after_login=${currentUrl}`
        )
      }
      else if(redirectToUrl.match(/\/auth\/login/i)) {
        redirectToUrl = `${redirectToUrl}?after_login=${currentUrl}`
      }

      // redirect and throw an error. This error will be catched by
      // Promisse catch block in each request.
      if (currentUrl != redirectToUrl) window.location.replace(redirectToUrl);
      throw new Error('Your session has expired. You will be redirected to the login page!')
    }
    return response;

  }, function (error) {
    // Do something with response error
    return Promise.reject(error);
  });

  return axiosInstance;
};
