#
# Adds a loading spinner and dimms the table when clicking pagination icons.
# When using Ajax:
# If pagination happens with ajax the PaginationSpinner should be reloaded.
#
class PaginationSpinner

  constructor: (options) ->
    @el = options.el
    @initialize options

  initialize: (@options) ->
    if @el.find('.pagination-wrapper').length == 0
      # create a wrapper for the table
      @el.wrapInner( "<div class='pagination-wrapper'></div>" );
      @el.find('.pagination-wrapper').wrapInner( "<div class='pagination-content'></div>" );
      # add the spinner element
      @el.find('.pagination-wrapper').prepend('<span class="spinner hide"></span>' );
      # add event to the pagination links
      @el.find('ul.pagination a').click (event) =>
        @el.find('.pagination-content').addClass('dimmed')
        @el.find('.pagination-wrapper .spinner').removeClass('hide')

$.fn.initPaginationSpinner = (options) ->
  options = options || {}
  this.each () ->
    options.el = $(this)
    new PaginationSpinner(options)

$ ->
  # when modal start pagination
  $(document).on 'modal:contentUpdated', ->
    $('[data-toggle="paginationSpinner"]').initPaginationSpinner()

  # when full layout start also pagination
  $('[data-toggle="paginationSpinner"]').initPaginationSpinner()
