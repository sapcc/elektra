class PaginationSpinner

  constructor: (options) ->
    @el = options.el
    @initialize options

  initialize: (@options) ->
    # create a wrapper for the table
    @el.find('table').wrap( "<div class='pagination-wrapper'></div>" );
    # add the spinner element
    @el.find('.pagination-wrapper').prepend('<span class="spinner hide"></p>' );
    # add event to the pagination links
    @el.find('ul.pagination a').click (event) =>
      @el.find('table').addClass('dimmed')
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