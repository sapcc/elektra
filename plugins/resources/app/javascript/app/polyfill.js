//Object.fromEntries() is not supported by Chrome yet.
export const objectFromEntries = (entries) => {
  const result = {};
  for (let [k,v] of entries) {
    result[k] = v;
  }
  return result;
};

//Array.flatMap() is not supported on some older browsers that customers use.
export const arrayFlatMap = (inputs, callback) => {
  const outputs = [];
  for (let value of inputs) {
    outputs.push(...callback(value));
  }
  return outputs;
};
