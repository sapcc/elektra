export const isEmpty = (s) => (!s && s.length == 0 ? true : false)
export const truncate = (s, length) => (s || "").substring(0, length - 3) + "..."

export const isValidUrl = (url) => {
  try {
    const parsedUrl = new URL(url, window.location.origin) // Supports relative URLs
    return parsedUrl.protocol === "http:" || parsedUrl.protocol === "https:" // Allow only HTTP(S)
  } catch (e) {
    return false // Invalid URL
  }
}
