export const byteToHuman = (bytes) => {
  const kb = parseFloat(bytes)/1024
  if(kb < 1) return `${bytes}Byte`
  const mb = kb/1024
  if(mb < 1) return `${Number(kb.toFixed(2))}KB`
  const gb = mb/1024
  if(gb < 1) return `${Number(mb.toFixed(2))}MB`
  const tb = gb/1024
  if(tb < 1) return `${Number(gb.toFixed(2))}GB`
  return `${Number(tb.toFixed(2))}TB`
}
