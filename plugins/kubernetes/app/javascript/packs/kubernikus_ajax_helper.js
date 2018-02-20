import axios from 'axios';

export let kubernikusAjaxHelper;

export const configureKubernikusAjaxHelper = (baseURL, token) => {

  kubernikusAjaxHelper = axios.create({
    baseURL,
    timeout: 60000,
    headers: {
                'Accept': 'application/json; charset=utf-8',
                'X-Auth-Token': token
             }
  });

};
