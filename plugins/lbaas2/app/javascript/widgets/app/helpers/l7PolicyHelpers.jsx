import React from "react"

export const actionTypes = () => {
  return [
    { value: "REDIRECT_PREFIX", label: "REDIRECT_PREFIX" },
    { value: "REDIRECT_TO_POOL", label: "REDIRECT_TO_POOL" },
    { value: "REDIRECT_TO_URL", label: "REDIRECT_TO_URL" },
    { value: "REJECT", label: "REJECT" },
  ]
}

export const codeTypes = () => {
  return [
    { value: "301", label: "301" },
    { value: "302", label: "302" },
    { value: "303", label: "303" },
    { value: "307", label: "307" },
    { value: "308", label: "308" },
  ]
}

export const actionRedirect = (action) => {
  switch (action) {
    case "REDIRECT_PREFIX":
      return [
        { value: "redirect_http_code", label: "HTTP Code" },
        { value: "redirect_prefix", label: "Prefix" },
      ]
    case "REDIRECT_TO_POOL":
      return [{ value: "redirect_pool_id", label: "Pool ID" }]
    case "REDIRECT_TO_URL":
      return [
        { value: "redirect_http_code", label: "HTTP Code" },
        { value: "redirect_url", label: "URL" },
      ]
    default:
      return []
  }
}
