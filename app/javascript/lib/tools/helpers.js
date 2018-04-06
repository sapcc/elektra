export const isEmpty = (s) => (!s && s.length == 0) ? true : false
export const truncate = (s, length) => (s || '').substring(0,length-3)+'...';
