export const regexString = (string) =>
  string.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&")
