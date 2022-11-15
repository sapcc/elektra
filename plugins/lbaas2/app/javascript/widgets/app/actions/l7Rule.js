import { ajaxHelper } from "lib/ajax_helper"

export const fetchL7Rules = (lbID, listenerID, l7Policy, options) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(
        `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7Policy}/l7rules`,
        { params: options }
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const fetchL7Rule = (lbID, listenerID, l7PolicyID, l7RuleID) => {
  return new Promise((handleSuccess, handleError) => {
    ajaxHelper
      .get(
        `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7RuleID}`
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleError(error)
      })
  })
}

export const postL7Rule = (lbID, listenerID, l7PolicyID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .post(
        `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules`,
        { l7rule: values }
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const putL7Rule = (lbID, listenerID, l7PolicyID, l7ruleID, values) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(
        `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7ruleID}`,
        { l7rule: values }
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}

export const deleteL7Rule = (lbID, listenerID, l7PolicyID, l7RuleID) => {
  return new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .delete(
        `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7RuleID}`
      )
      .then((response) => {
        handleSuccess(response.data)
      })
      .catch((error) => {
        handleErrors(error)
      })
  })
}
