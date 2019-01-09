import { STRINGS } from './constants';

// Translates API-level strings into user-readable strings,
// e.g. "volumev2" -> "Block Storage".
export const t = (str) => (STRINGS[str] || str);

// This can be used as a sorting predicate:
//
//     sorted_things = things.sort(byUIString)
export const byUIString = (a, b) => {
  const aa = STRINGS[a] || a;
  const bb = STRINGS[b] || b;
  return (aa < bb) ? -1 : (aa > bb) ? 1 : 0;
};
