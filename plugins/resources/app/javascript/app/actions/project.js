import { pluginAjaxHelper } from 'ajax_helper';

// the global `ajaxHelper` is set up in init.js to talk to the Limes API, so we
// need a separate AJAX helper for talking to Elektra
const elektraAjaxHelper = pluginAjaxHelper('resources', {
  headers: {'X-Requested-With': 'XMLHttpRequest'},
});

const elektraErrorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message

