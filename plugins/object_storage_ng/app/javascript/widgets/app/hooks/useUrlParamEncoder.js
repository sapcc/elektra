const KEY = "__$"

const encodeUrlParam = (value) => encodeURIComponent(btoa(`${KEY}=${value}`))
const decodeUrlParam = (hash) => {
  if (!hash) return ""
  let content = atob(decodeURIComponent(hash))
  if (content.indexOf(`${KEY}=`) !== 0) return ""
  return content.replace(`${KEY}=`, "")
}

export default (value) => ({
  value: decodeUrlParam(value),
  encode: encodeUrlParam,
})
