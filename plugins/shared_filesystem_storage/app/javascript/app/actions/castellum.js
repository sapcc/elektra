import { createAjaxHelper } from 'ajax_helper';

var ajaxHelper = null;

export const configureCastellumAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts);
};
