import { STRINGS } from './constants';

const perFlavorRx = /^instances_(.+)$/;

// Translates API-level strings into user-readable UI strings,
// e.g. "volumev2" -> "Block Storage".
export const t = (str) => {
  //for baremetal flavor resources like "instances_zh2vic1.medium",
  //return the flavor name, e.g. "zh2vic1.medium"
  const match = perFlavorRx.exec(str);
  if (match) {
    return match[1];
  }

  return STRINGS[str] || str;
}

// This can be used as a sorting predicate:
//     sorted_things = things.sort(byUIString)
export const byUIString = (a, b) => {
  const aa = t(a);
  const bb = t(b);
  return (aa < bb) ? -1 : (aa > bb) ? 1 : 0;
};
