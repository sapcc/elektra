import React from "react";
import { ajaxHelper } from "ajax_helper";
import { useDispatch } from "../../app/components/StateProvider";
import { confirm } from "lib/dialogs";
import { addNotice, addError } from "lib/flashes";
import { ErrorsList } from "lib/elektra-form/components/errors_list";

const useL7Rule = () => {
  const dispatch = useDispatch();

  const fetchL7Rules = (lbID, listenerID, l7Policy, marker) => {
    return new Promise((handleSuccess, handleError) => {
      const params = {};
      if (marker) params["marker"] = marker.id;
      ajaxHelper
        .get(
          `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7Policy}/l7rules`,
          { params: params }
        )
        .then((response) => {
          handleSuccess(response.data);
        })
        .catch((error) => {
          handleError(error);
        });
    });
  };

  const persistL7Rules = (lbID, listenerID, l7Policy, marker) => {
    dispatch({ type: "RESET_L7RULES" });
    dispatch({ type: "REQUEST_L7RULES" });
    return new Promise((handleSuccess, handleError) => {
      fetchL7Rules(lbID, listenerID, l7Policy, marker)
        .then((data) => {
          dispatch({
            type: "RECEIVE_L7RULES",
            items: data.l7rules,
            hasNext: data.has_next,
          });
          handleSuccess(data);
        })
        .catch((error) => {
          dispatch({ type: "REQUEST_L7RULES_FAILURE", error: error });
          handleError(error.response);
        });
    });
  };

  const fetchL7Rule = (lbID, listenerID, l7PolicyID, l7RuleID) => {
    return new Promise((handleSuccess, handleError) => {
      ajaxHelper
        .get(
          `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7RuleID}`
        )
        .then((response) => {
          handleSuccess(response.data);
        })
        .catch((error) => {
          handleError(error.response);
        });
    });
  };

  const persistL7Rule = (lbID, listenerID, l7PolicyID, l7RuleID) => {
    return new Promise((handleSuccess, handleError) => {
      fetchL7Rule(lbID, listenerID, l7PolicyID, l7RuleID)
        .then((data) => {
          dispatch({ type: "RECEIVE_L7RULE", l7Rule: data.l7rule });
          handleSuccess(data);
        })
        .catch((error) => {
          if (error && error.status == 404) {
            dispatch({ type: "REMOVE_L7RULE", id: l7RuleID });
          }
          handleError(error.response);
        });
    });
  };

  const createL7Rule = (lbID, listenerID, l7PolicyID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .post(
          `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules`,
          { l7rule: values }
        )
        .then((response) => {
          dispatch({ type: "RECEIVE_L7RULE", l7Rule: response.data });
          handleSuccess(response);
        })
        .catch((error) => {
          handleErrors(error);
        });
    });
  };

  const updateL7Rule = (lbID, listenerID, l7PolicyID, l7ruleID, values) => {
    return new Promise((handleSuccess, handleErrors) => {
      ajaxHelper
        .put(
          `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7ruleID}`,
          { l7rule: values }
        )
        .then((response) => {
          dispatch({ type: "RECEIVE_L7RULE", l7Rule: response.data.l7rule });
          handleSuccess(response);
        })
        .catch((error) => {
          handleErrors(error);
        });
    });
  };

  const setSearchTerm = (searchTerm) => {
    dispatch({ type: "SET_L7RULES_SEARCH_TERM", searchTerm: searchTerm });
  };

  const errorMessage = (err) => {
    return (err.data && (err.data.errors || err.data.error)) || err.message;
  };

  const displayInvert = (invert) => {
    if (invert) {
      return <i className="fa fa-check" />;
    } else {
      return <i className="fa fa-times" />;
    }
  };

  const confirmMessageOnDelete = (l7Rule) => {
    return (
      <React.Fragment>
        <p>Do you really want to delete following L7 Rule?</p>
        <p>
          <b>ID:</b> {l7Rule.id}
          <br />
          <b>Type:</b> {l7Rule.type}
          <br />
          <b>Compare Type:</b> {l7Rule.compare_type}
          <br />
          <b>Invert:</b> {displayInvert(l7Rule.invert)}
          <br />
          <b>Key:</b> {l7Rule.key}
          <br />
          <b>Value:</b>{" "}
          {l7Rule.value && l7Rule.value.length > 50
            ? `${l7Rule.value.slice(0, 50)}...`
            : l7Rule.value}
        </p>
      </React.Fragment>
    );
  };

  const deleteL7Rule = (lbID, listenerID, l7PolicyID, l7Rule) => {
    return new Promise((handleSuccess, handleErrors) => {
      confirm(confirmMessageOnDelete(l7Rule))
        .then(() => {
          return ajaxHelper
            .delete(
              `/loadbalancers/${lbID}/listeners/${listenerID}/l7policies/${l7PolicyID}/l7rules/${l7Rule.id}`
            )
            .then((response) => {
              dispatch({ type: "REQUEST_REMOVE_L7RULE", id: l7Rule.id });
              addNotice(
                <React.Fragment>
                  <span>
                    L7 Rule <b>{l7Rule.id}</b> will be deleted.
                  </span>
                </React.Fragment>
              );
              handleSuccess();
            })
            .catch((error) => {
              addError(
                React.createElement(ErrorsList, {
                  errors: errorMessage(error.response),
                })
              );
              handleErrors();
            });
        })
        .catch((cancel) => {
          if (cancel !== true) {
            addError(
              React.createElement(ErrorsList, {
                errors: cancel.toString(),
              })
            );
          }

          return true;
        });
    });
  };

  const ruleTypes = () => {
    return [
      {
        label: "COOKIE",
        value: "COOKIE",
        description:
          "The rule looks for a cookie named by the key parameter and compares it against the value parameter in the rule.",
      },
      {
        label: "FILE_TYPE",
        value: "FILE_TYPE",
        description:
          "The rule compares the last portion of the URI against the value parameter in the rule. (eg. txt, jpg).",
      },
      {
        label: "HEADER",
        value: "HEADER",
        description:
          "The rule looks for a header defined in the key parameter and compares it against the value parameter in the rule.",
      },
      {
        label: "HOST_NAME",
        value: "HOST_NAME",
        description:
          "The rule does a comparison between the HTTP/1.1 hostname in the request against the value parameter in the rule.",
      },
      {
        label: "PATH",
        value: "PATH",
        description:
          "The rule compares the path portion of the HTTP URI against the value parameter in the rule.",
      },
      {
        label: "SSL_CONN_HAS_CERT",
        value: "SSL_CONN_HAS_CERT",
        description:
          "The rule will match if the client has presented a certificate for TLS client authentication. This does not imply the certificate is valid.",
      },
      {
        label: "SSL_VERIFY_RESULT",
        value: "SSL_VERIFY_RESULT",
        description:
          "This rule will match the TLS client authentication certificate validation result. A value of ‘0’ means the certificate was successfully validated. A value greater than ‘0’ means the certificate failed validation. This value follows the openssl-verify result codes.",
      },
      {
        label: "SSL_DN_FIELD",
        value: "SSL_DN_FIELD",
        description:
          "The rule looks for a Distinguished Name field defined in the key parameter and compares it against the value parameter in the rule.",
      },
    ];
  };

  const ruleTypeKeyRelation = (type) => {
    let showKeyAttribute = false;
    if (type == "COOKIE" || type == "HEADER") {
      showKeyAttribute = true;
    }
    return showKeyAttribute;
  };

  const ruleCompareTypes = () => {
    return [
      { label: "CONTAINS", value: "CONTAINS", description: "String contains" },
      {
        label: "ENDS_WITH",
        value: "ENDS_WITH",
        description: "String ends with",
      },
      {
        label: "EQUAL_TO",
        value: "EQUAL_TO",
        description: "String is equal to",
      },
      {
        label: "REGEX",
        value: "REGEX",
        description: "Perl type regular expression matching",
      },
      {
        label: "STARTS_WITH",
        value: "STARTS_WITH",
        description: "String starts with",
      },
    ];
  };

  return {
    fetchL7Rules,
    persistL7Rules,
    fetchL7Rule,
    persistL7Rule,
    createL7Rule,
    updateL7Rule,
    ruleTypes,
    ruleTypeKeyRelation,
    ruleCompareTypes,
    deleteL7Rule,
    setSearchTerm,
    displayInvert,
  };
};

export default useL7Rule;
