# jQuery plugin
jQuery.fn.searchable= ( options ) ->
  defaults =
    searchModeCssClass: 'search-mode'
    searchResultCssClass: 'search-result'
    hasSearchResultCssClass: 'has-search-result'
    searchInputCssClass: 'search-input'
    searchInputWrapperCssClass: 'search-input-wrapper'
    searchInputType: 'clearButton'
    searchIconCssClass: 'fa-search'
    searchIconClearCssClass: 'fa-times-circle'

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
        try
          regex = new RegExp($.trim(value), "i")
        catch e
          return false

        $(this).data('searchName').search(regex)>=0

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
      $inputWrapper = $("<div class='#{settings.searchInputWrapperCssClass}'></div>").insertBefore($searchableList)
      $("<input type='text' class='#{settings.searchInputCssClass}'/>").appendTo($inputWrapper)


    # Add search icon
    $searchIconWrapper = $("<span class='form-control-feedback'></span>").insertAfter($searchInput)
    $searchIcon = $("<i class='fa #{settings.searchIconCssClass}'></i>").appendTo($searchIconWrapper)
    # search icon behaviour
    $searchIconWrapper.click ->
      # clicking on the wrapper will empty the search input if it's currently not empty
      if $searchInput.val().length > 0
        $searchInput.val('') # empty input
        $searchIcon.removeClass("#{settings.searchIconClearCssClass}").addClass("#{settings.searchIconCssClass}") # switch icon class back to magnifying glass
        $searchIconWrapper.removeClass("not-empty") # this class is necessary to be able to style the wrapper depending on which icon is displayed


      updateSearchResult($searchableList,$searchInput.val())

    if action
      switch action
        when 'update' then updateSearchResult($searchableList,$searchInput.val())
    else
      # new value in search input is presented
      $searchInput.keyup () ->
        # switch search icon from magnifying glass to clear icon and back depending on whether the search input is empty or not
        if $searchInput.val().length > 0
          $searchIcon.removeClass("#{settings.searchIconCssClass}").addClass("#{settings.searchIconClearCssClass}")
          $searchIconWrapper.addClass("not-empty") # for styling the wrapper
        else
          $searchIcon.removeClass("#{settings.searchIconClearCssClass}").addClass("#{settings.searchIconCssClass}")
          $searchIconWrapper.removeClass("not-empty")

        updateSearchResult($searchableList,$searchInput.val())

      $searchableList.bind('DOMNodeInserted DOMNodeRemoved', () -> updateSearchResult($searchableList,$searchInput.val()))
