/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//
// Adds a loading spinner and dimms the table when clicking pagination icons.
// When using Ajax:
// If pagination happens with ajax the PaginationSpinner should be reloaded.
//
class PaginationSpinner {
  constructor(options) {
    this.el = options.el
    this.initialize(options)
  }

  initialize(options) {
    this.options = options
    if (this.el.find(".pagination-wrapper").length === 0) {
      // create a wrapper for the table
      this.el.wrapInner("<div class='pagination-wrapper'></div>")
      this.el
        .find(".pagination-wrapper")
        .wrapInner("<div class='pagination-content'></div>")
      // add the spinner element
      this.el
        .find(".pagination-wrapper")
        .prepend('<span class="spinner hide"></span>')
      // add event to the pagination links
      return this.el.find("ul.pagination a").click((event) => {
        this.el.find(".pagination-content").addClass("dimmed")
        return this.el.find(".pagination-wrapper .spinner").removeClass("hide")
      })
    }
  }
}

$.fn.initPaginationSpinner = function (options) {
  options = options || {}
  return this.each(function () {
    options.el = $(this)
    return new PaginationSpinner(options)
  })
}

$(function () {
  // when modal start pagination
  $(document).on("modal:contentUpdated", () =>
    $('[data-toggle="paginationSpinner"]').initPaginationSpinner()
  )

  // when full layout start also pagination
  return $('[data-toggle="paginationSpinner"]').initPaginationSpinner()
})
