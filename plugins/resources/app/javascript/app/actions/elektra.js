import { pluginAjaxHelper } from 'ajax_helper';

import { Scope } from '../scope';

// the global `ajaxHelper` is set up in init.js to talk to the Limes API, so we
// need a separate AJAX helper for talking to Elektra
const ajaxHelper = pluginAjaxHelper('resources', {
  headers: {'X-Requested-With': 'XMLHttpRequest'},
});

const elektraErrorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message

export const sendQuotaRequest = (scopeData, requestBody) => {
  const scope = new Scope(scopeData);

  return new Promise((resolve, reject) =>
    ajaxHelper.post(`/request/${scope.level()}`, requestBody)
      .then(response => {
        if (response.data.errors) { reject(response.data.errors); }
        else { resolve(response.data); }
      })
      .catch(error => reject({ errors: elektraErrorMessage(error) }))
  );
}
