const KEY = "__$"

const encodeUrlParam = (value) => encodeURIComponent(btoa(`${KEY}=${value}`))
const decodeUrlParam = (hash) => {
  if (!hash) return ""
  let content = atob(decodeURIComponent(hash))
  if (content.indexOf(`${KEY}=`) !== 0) return ""
  return content.replace(`${KEY}=`, "")
}

const parse = (encodedValue) => {
  const value = encodedValue ? decodeUrlParam(encodedValue) : ""
  return {
    value,
    getFileName: (filePath) =>
      filePath ? decodeURIComponent(filePath).replace(value, "") : filePath,
    encode: encodeUrlParam,
  }
}

export default parse
