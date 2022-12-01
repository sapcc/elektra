/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

class Collapsable {
  constructor(elem, options) {
    let error
    this.options = options || {}
    this.$content = $(elem)
    if (this.$content.data("registered")) {
      return
    }
    this.$content.data("registered", true)

    const lineHeight = (() => {
      try {
        return parseInt(this.$content.css("lineHeight"))
      } catch (error1) {
        error = error1
        return 20
      }
    })()

    const height = (() => {
      try {
        return this.$content.height()
      } catch (error2) {
        error = error2
        return 30
      }
    })()

    // console.log 'lineHeight', lineHeight
    // console.log 'height', height

    if (height > lineHeight * 2) {
      this.buildCollapseContainer()
    }
  }

  buildCollapseContainer() {
    // eslint-disable-next-line no-prototype-builtins
    const collapsed = this.options.hasOwnProperty("collapsed")
      ? this.options.collapsed
      : this.$content.is("[data-collapsed]")

    this.$content
      .wrap(
        `<div class="collapsable ${collapsed ? "collapsed" : undefined}"></div>`
      )
      .addClass("collapsable-content")

    const $toggleButton = $(
      '<a href="#" class="collapsable-toggle-button"><i></i></a>'
    ).insertBefore(this.$content)
    // .click (e) =>
    //   e.preventDefault()
    //   @$content.closest('.collapsable').toggleClass('collapsed')

    const $container = this.$content.closest(".collapsable")
    return $container.click((e) => {
      e.preventDefault()
      return $container.toggleClass("collapsed")
    })
  }
}

$.fn.collapsable = function (options) {
  if (options == null) {
    options = {}
  }
  return this.each((index, elem) => new Collapsable(elem, options))
}
