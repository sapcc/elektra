/**
 * This function converts every token in a string to camel case.
 * @example project id => Project ID
 * @example created_at => Created At
 * @param {string} input
 * @returns
 */
export function titleCase(str) {
  if (!str) return ""
  var splitStr = str.replace(/_/g, " ").toLowerCase().split(" ")
  for (var i = 0; i < splitStr.length; i++) {
    if (splitStr[i] === "id") splitStr[i] = "ID"
    // You do not need to check if i is larger than splitStr length, as your for does that for you
    // Assign it back to the array
    splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1)
  }
  // Directly return the joined string
  return splitStr.join(" ")
}
