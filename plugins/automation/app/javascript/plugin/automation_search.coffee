class AutomationSearch

  constructor: (options) ->
    @el = options.el
    @initialize options

  initialize: (@options) ->
    # css class of the dimmed and render area
    this.searchDimmedArea = @el.data('search-dimmed-area')
    this.searchRenderArea = @el.data('search-render-area')
    this.searchErrorArea = @el.data('search-error-area')
    # add spinner to the dimmed area
    $('.'+this.searchDimmedArea).prepend('<span class="search-spinner hide"></p>' );
    # event on submit input
    @el.find('form').on 'submit', $.proxy(search, this)

  search= (e) ->
    e.stopPropagation()
    e.preventDefault()
    searchbaseUrl = $(e.target).attr('action')
    searchValue = this.el.find('input#js-search_input').val()
    # remove error content
    $('.'+this.searchErrorArea).html('')
    # add search services
    searchUrl = buildUrl(searchbaseUrl, 'search_service', true)
    # add search value
    searchUrl = buildUrl(searchUrl, 'search', searchValue)
    dimmArea(this, true)
    filter(this, searchUrl, 0)

  filter= (_this, searchUrl, timeout) ->
    $this = _this
    setTimeout(
      =>
        $.get(searchUrl)
        .done (data, status, xhr)->
          dimmArea($this, false)
          $('.'+$this.searchRenderArea).html(data)
          # reload the pagination spinner in case there is
          $('[data-toggle="paginationSpinner"]').initPaginationSpinner()
        .fail () ->
          dimmArea($this, false)
          $('.'+$this.searchErrorArea).html('Search error. Try again later.')


      timeout
    )

  dimmArea= (_this, shouldDimm) ->
    if _this.searchDimmedArea != ''
      if shouldDimm
        _this.el.find('input').attr('disabled', 'disabled')
        _this.el.find('button[type=submit]').attr('disabled', 'disabled')
        $('.'+_this.searchDimmedArea).addClass('dimmed')
        $('.'+_this.searchDimmedArea).find('.search-spinner').removeClass('hide')
      else
        _this.el.find('input').removeAttr('disabled')
        _this.el.find('button[type=submit]').removeAttr('disabled', 'disabled')
        $('.'+_this.searchDimmedArea).removeClass('dimmed')
        $('.'+_this.searchDimmedArea).find('.search-spinner').addClass('hide')

  buildUrl= (base, key, value) ->
    if typeof base == 'undefined'
      base = ""
    sep = if (base.indexOf('?') > -1) then '&' else '?'
    base + sep + key + '=' + value

$.fn.initAutomationSearch = (options) ->
  options = options || {}
  this.each () ->
    options.el = $(this)
    new AutomationSearch(options)

$ ->
  # when modal
  $(document).on 'modal:contentUpdated', ->
    $('[data-toggle="automationSearch"]').initAutomationSearch()

  # when full layout start also pagination
  $('[data-toggle="automationSearch"]').initAutomationSearch()
