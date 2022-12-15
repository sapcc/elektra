import React from "react"

// HTTP, HTTPS, PING, TCP, TLS-HELLO, or UDP-CONNECT
export const healthMonitorTypes = () => {
  return [
    { label: "HTTP", value: "HTTP" },
    { label: "HTTPS", value: "HTTPS" },
    { label: "PING", value: "PING" },
    { label: "TCP", value: "TCP" },
    { label: "TLS-HELLO", value: "TLS-HELLO" },
    { label: "UDP-CONNECT", value: "UDP-CONNECT" },
  ]
}

export const httpMethodRelation = (type) => {
  switch (type) {
    case "HTTP":
      return true
    case "HTTPS":
      return true
    default:
      return false
  }
}

export const expectedCodesRelation = (type) => {
  switch (type) {
    case "HTTP":
      return true
    case "HTTPS":
      return true
    default:
      return false
  }
}

export const urlPathRelation = (type) => {
  switch (type) {
    case "HTTP":
      return true
    case "HTTPS":
      return true
    default:
      return false
  }
}

export const httpMethods = () => {
  return [
    { label: "CONNECT", value: "CONNECT" },
    { label: "DELETE", value: "DELETE" },
    { label: "GET", value: "GET" },
    { label: "HEAD", value: "HEAD" },
    { label: "OPTIONS", value: "OPTIONS" },
    { label: "PATCH", value: "PATCH" },
    { label: "POST", value: "POST" },
    { label: "PUT", value: "PUT" },
    { label: "TRACE", value: "TRACE" },
  ]
}
