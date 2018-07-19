#SET CURSOR POSITION
$.fn.setCursorPosition = (pos) ->
  this.each (index, elem) ->
    if elem.setSelectionRange
      console.log 'setSelectionRange', pos
      elem.setSelectionRange(pos, pos)
    else if elem.createTextRange
      console.log 'createTextRange'
      range = elem.createTextRange()
      range.collapse(true)
      range.moveEnd('character', pos)
      range.moveStart('character', pos)
      range.select()
    
  return this

    
