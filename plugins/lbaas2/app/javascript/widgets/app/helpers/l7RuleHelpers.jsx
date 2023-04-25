import React from "react"
import BooleanLabel from "../components/shared/BooleanLabel"

export const confirmMessageOnDelete = (l7Rule) => {
  return (
    <>
      <p>Do you really want to delete following L7 Rule?</p>
      <p>
        <b>ID:</b> {l7Rule.id}
        <br />
        <b>Type:</b> {l7Rule.type}
        <br />
        <b>Compare Type:</b> {l7Rule.compare_type}
        <br />
        <b>Invert:</b> <BooleanLabel value={l7Rule.invert} />
        <br />
        <b>Key:</b> {l7Rule.key}
        <br />
        <b>Value:</b>{" "}
        {l7Rule.value && l7Rule.value.length > 50
          ? `${l7Rule.value.slice(0, 50)}...`
          : l7Rule.value}
      </p>
    </>
  )
}

export const ruleTypes = () => {
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
  ]
}

export const ruleTypeKeyRelation = (type) => {
  let showKeyAttribute = false
  if (type == "COOKIE" || type == "HEADER") {
    showKeyAttribute = true
  }
  return showKeyAttribute
}

export const ruleCompareTypes = () => {
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
      label: "STARTS_WITH",
      value: "STARTS_WITH",
      description: "String starts with",
    },
  ]
}
