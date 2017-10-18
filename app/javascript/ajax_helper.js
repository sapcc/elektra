import axios from 'axios';

export let ajaxHelper;

export const configureAjaxHelper = () => {
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
    timeout: 10000,
    headers
  })
};
