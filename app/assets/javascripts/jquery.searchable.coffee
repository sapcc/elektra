# jQuery plugin
jQuery.fn.searchable= ( options ) ->
  defaults =
    searchModeCssClass: 'search-mode'
    searchResultCssClass: 'search-result'
    hasSearchResultCssClass: 'has-search-result'
    searchInputCssClass: 'search-input'

  # merge defaults and options
  if typeof options is 'string'
    action = options
    options ={}

  settings = $.extend( {}, defaults, options )

  updateSearchResult=($list,value)->
    # reset searchable list -> remove search classes
    $list.removeClass(settings.searchModeCssClass)
    $list.find(".#{settings.searchResultCssClass}").removeClass(settings.searchResultCssClass)
    $list.find(".#{settings.hasSearchResultCssClass}").removeClass(settings.hasSearchResultCssClass)

    if value
      # search input is not empty
      # mark searchable list with the css class settings.searchModeCssClass
      $list.addClass(settings.searchModeCssClass)

      # mark each element which matches the value with the css class settings.searchResultCssClass
      $elements = $list.find('*[data-search-name]').filter () ->
        $(this).data('searchName').search(new RegExp($.trim(value), "i"))>=0

      # mark each parent of found element with the css class settings.hasSearchModeCssClass
      $elements.each (index) ->
        $(this).addClass(settings.searchResultCssClass)
        $(this).parents("*[data-search-name]").addClass(settings.hasSearchResultCssClass)


  # for each element found by selector
  this.each () ->
    # this element is the searchable list
    $searchableList = $(this)
    # get data attributes
    data = $searchableList.data()
    # find or create search input field
    $searchInput = if data.searchInput && $(data.searchInput).length>0
      $(data.searchInput)
    else
      $inputWrapper = $("<div class='#{settings.searchInputCssClass}-wrapper'></div>").insertBefore($searchableList)
      $("<input type='text' class='#{settings.searchInputCssClass}'/>").appendTo($inputWrapper)

    if action
      switch action
        when 'update' then updateSearchResult($searchableList,$searchInput.val())
    else
      # new value in search input is presented
      $searchInput.keyup () ->
        updateSearchResult($searchableList,$searchInput.val())

      $searchableList.bind('DOMNodeInserted DOMNodeRemoved', () -> updateSearchResult($searchableList,$searchInput.val()))
