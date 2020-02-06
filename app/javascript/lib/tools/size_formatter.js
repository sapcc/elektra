const nbsp = '\xA0'; //a non-breaking space

export const byteToHuman = (bytes) => {
  const kb = parseFloat(bytes)/1024
  if(kb < 1) return `${bytes}${nbsp}Byte`
  const mb = kb/1024
  if(mb < 1) return `${Number(kb.toFixed(2))}${nbsp}KiB`
  const gb = mb/1024
  if(gb < 1) return `${Number(mb.toFixed(2))}${nbsp}MiB`
  const tb = gb/1024
  if(tb < 1) return `${Number(gb.toFixed(2))}${nbsp}GiB`
  return `${Number(tb.toFixed(2))}${nbsp}TiB`
}
