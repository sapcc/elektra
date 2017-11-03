import axios from 'axios';

export let ajaxHelper;

export const configureAjaxHelper = (window) => {
  // get current url without params and bind it to baseURL
  let baseURL = `${window.location.origin}${window.location.pathname}`;
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
  if (csrfToken) Object.assign(headers,{'x-csrf-token': csrfToken})

  // setup ajaxHelper
  ajaxHelper = axios.create({
    baseURL,
    timeout: 60000,
    headers
  })
  // overwrite default Accept Header to use json only
  ajaxHelper.defaults.headers.common['Accept'] = 'application/json; charset=utf-8';

  // Add a response interceptor
  ajaxHelper.interceptors.response.use(function (response) {
    // Check if location exists in the response headers
    if (response && response.headers && response.headers.location) {
      // location is presented -> build the redirect url
      let currentUrl = encodeURIComponent(window.location.href)
      let redirectToUrl = response.headers.location.replace(
        /after_login=(.*)/g, `after_login=${currentUrl}`
      )
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

};
