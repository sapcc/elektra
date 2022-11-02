import React from "react"
import { ajaxHelper } from "lib/ajax_helper"
import { useDispatch } from "../../components/StateProvider"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"
import { errorMessage } from "../../helpers/commonHelpers"
import {
  fetchL7Rules,
  fetchL7Rule,
  postL7Rule,
  putL7Rule,
  deleteL7Rule,
} from "../../actions/l7Rule"
import { confirmMessageOnDelete } from "../../helpers/l7RuleHelpers"

const useL7Rule = () => {
  const dispatch = useDispatch()

  const persistL7Rules = (lbID, listenerID, l7Policy, options) => {
    dispatch({ type: "RESET_L7RULES" })
    dispatch({ type: "REQUEST_L7RULES" })
    return new Promise((handleSuccess, handleError) => {
      fetchL7Rules(lbID, listenerID, l7Policy, options)
        .then((data) => {
          dispatch({
            type: "RECEIVE_L7RULES",
            items: data.l7rules,
            hasNext: data.has_next,
          })
          handleSuccess(data)
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_L7RULES_FAILURE", error: error })
          handleError(error)
        })
    })
  }

  const persistL7Rule = (lbID, listenerID, l7PolicyID, l7RuleID) => {
    return new Promise((handleSuccess, handleError) => {
      fetchL7Rule(lbID, listenerID, l7PolicyID, l7RuleID)
        .then((data) => {
          dispatch({ type: "RECEIVE_L7RULE", l7Rule: data.l7rule })
          handleSuccess(data)
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_L7RULE", id: l7RuleID })
          }
          handleError(error)
        })
    })
  }

  const createL7Rule = (lbID, listenerID, l7PolicyID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      postL7Rule(lbID, listenerID, l7PolicyID, values)
        .then((data) => {
          dispatch({ type: "RECEIVE_L7RULE", l7Rule: data.l7rule })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const updateL7Rule = (lbID, listenerID, l7PolicyID, l7ruleID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      putL7Rule(lbID, listenerID, l7PolicyID, l7ruleID, values)
        .then((data) => {
          dispatch({ type: "RECEIVE_L7RULE", l7Rule: data.l7rule })
          handleSuccess(data)
        })
        .catch((error) => {
          handleErrors(error)
        })
    })
  }

  const setSearchTerm = (searchTerm) => {
    dispatch({ type: "SET_L7RULES_SEARCH_TERM", searchTerm: searchTerm })
  }

  const removeL7Rule = (lbID, listenerID, l7PolicyID, l7Rule) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(confirmMessageOnDelete(l7Rule))
        .then(() => {
          return deleteL7Rule(lbID, listenerID, l7PolicyID, l7Rule.id)
            .then((data) => {
              dispatch({ type: "REQUEST_REMOVE_L7RULE", id: l7Rule.id })
              addNotice(
                <React.Fragment>
                  <span>
                    L7 Rule <b>{l7Rule.id}</b> will be deleted.
                  </span>
                </React.Fragment>
              )
              handleSuccess()
            })
            .catch((error) => {
              addError(
                React.createElement(ErrorsList, {
                  errors: errorMessage(error),
                })
              )
              handleErrors()
            })
        })
        .catch((cancel) => {
          if (cancel !== true) {
            addError(
              React.createElement(ErrorsList, {
                errors: cancel.toString(),
              })
            )
          }

          return true
        })
    })
  }
  return {
    persistL7Rules,
    persistL7Rule,
    createL7Rule,
    updateL7Rule,
    removeL7Rule,
    setSearchTerm,
  }
}

export default useL7Rule
