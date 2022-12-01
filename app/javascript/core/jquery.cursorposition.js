/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//SET CURSOR POSITION
$.fn.setCursorPosition = function (pos) {
  this.each(function (index, elem) {
    if (elem.setSelectionRange) {
      // console.log 'setSelectionRange', pos
      return elem.setSelectionRange(pos, pos)
    } else if (elem.createTextRange) {
      // console.log 'createTextRange'
      const range = elem.createTextRange()
      range.collapse(true)
      range.moveEnd("character", pos)
      range.moveStart("character", pos)
      return range.select()
    }
  })

  return this
}
