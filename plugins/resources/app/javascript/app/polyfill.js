//Object.fromEntries() is not supported by Chrome yet.
export const objectFromEntries = (entries) => {
  const result = {};
  for (let [k,v] of entries) {
    result[k] = v;
  }
  return result;
};
