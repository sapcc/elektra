# jQuery plugin
jQuery.fn.searchable= ( options ) ->
  defaults = 
    searchModeCssClass: 'search-mode'
    searchResultCssClass: 'search-result'
    hasSearchResultCssClass: 'has-search-result'
    searchInputCssClass: 'search-input'
 
  # merge defaults and options
  settings = $.extend( {}, defaults, options )

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

    # new value in search input is presented    
    $searchInput.keyup () ->
      # reset searchable list -> remove search classes
      $searchableList.removeClass(settings.searchModeCssClass)
      $searchableList.find(".#{settings.searchResultCssClass}").removeClass(settings.searchResultCssClass)
      $searchableList.find(".#{settings.hasSearchResultCssClass}").removeClass(settings.hasSearchResultCssClass)
      
      # get current value of search input
      value = $searchInput.val()
      if value.length>0 
        # search input is not empty
        # mark searchable list with the css class settings.searchModeCssClass
        $searchableList.addClass(settings.searchModeCssClass)   
        
        # mark each element which matches the value with the css class settings.searchResultCssClass
        $elements = $('*[data-search-name]').filter () -> 
          $(this).data('searchName').search(new RegExp(value, "i"))>=0
      
        # mark each parent of found element with the css class settings.hasSearchModeCssClass  
        $elements.each (index) ->
          $(this).addClass(settings.searchResultCssClass)
          $(this).parents("*[data-search-name]").addClass(settings.hasSearchResultCssClass)
      
