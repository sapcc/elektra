import { useParams, useHistory, Link, useRouteMatch } from "react-router-dom"

const encodeUrlParam = (value) => encodeURIComponent(btoa(`value=${value}`))
const decodeUrlParam = (hash) => {
  if (!hash) return ""
  return atob(decodeURIComponent(hash)).replace("value=", "")
}

export default (value) => ({
  value: decodeUrlParam(value),
  encode: encodeUrlParam,
})
