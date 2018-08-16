# jQuery plugin
jQuery.fn.ajaxPaginate= ( options ) ->
  # default values for all paginate plugins
  defaults =
    searchInputSelector: null
    listSelector: null
    loadNextButton: true
    loadAllButton: false
    loadNextLabel: 'Load Next'
    loadAllLabel: 'Load All'
    loadNextItemsCssClass: 'btn btn-primary btn-sm'
    loadAllItemsCssClass: 'btn btn-default btn-sm'

  # merge defaults and options
  settings = $.extend( {}, defaults, options )

  # for each element found by selector
  this.each () ->
    $container = $(this)
    # define spinner element
    $spinner = $('<div><span class="spinner"></span> Loading&hellip;</div>').appendTo($container).hide()
    # define buttons container
    $buttons = $('<div class="main-buttons"></div>').appendTo($container)
    # default only for the current pagination (this)
    searchInputSelector = $container.data('searchInputSelector') || settings.searchInputSelector
    listSelector = $container.data('listSelector') || settings.listSelector
    loadNextButton = if typeof $container.data('nextButton') != 'undefined' then $container.data('nextButton')==true else settings.loadNextButton
    loadAllButton = if typeof $container.data('allButton') != 'undefined' then $container.data('allButton')==true else settings.loadAllButton
    loadNextLabel = $container.data('nextLabel') || settings.loadNextLabel
    loadAllLabel = $container.data('allLabel') || settings.loadAllLabel
    loadNextItemsCssClass = $container.data('nextCssClass') || settings.loadNextItemsCssClass
    loadAllItemsCssClass = $container.data('allCssClass') || settings.loadAllItemsCssClass
    loadAllMode = false

    stopLoadAll = false
    loading = false

    # initial values
    # page
    $container.data('currentPage',1)
    # complete
    $container.data('completed',false)

    # show loading indicator (hide buttons)
    showLoading=() -> $buttons.stop().fadeOut 'fast', () -> $spinner.stop().show()
    # hide loading indicator and show buttons
    hideLoading=() -> $spinner.stop().hide(); unless $container.data('completed') then $buttons.stop().fadeIn('fast')

    loadNext=(callback) ->
      # return if there is an ajax load running
      if loading
        callback() if callback
        return
      # if completed call callback and return
      if $container.data('completed')
        callback() if callback
        return

      # get next page from container data
      nextPage = $container.data('currentPage')+1
      # get last marker
      marker = $($('*[data-marker-id]').last()).data('markerId')
      # load next items via ajax

      loading = true
      $.get '', {page: nextPage, marker: marker}, (data) ->
        loading = false
        # check if data is empty
        if (typeof data == 'undefined') or data.trim().length==0
          # data is empty -> completed
          $container.data('completed',true)
        else
          $container.data('completed',false)
          # update the list
          $(listSelector).append(data)
          # update the page count
          $container.data('currentPage',nextPage)
        # call the callback method
        callback(data) if callback

    # load recursively next items until all items are loaded or stopAllLoad is true
    loadAll=(callback) ->
      return if stopLoadAll
      if $container.data('completed')
        callback() if callback
        return
      # load next items
      loadNext (data) ->
        loadAll(callback)

    # if a search input selector is provided
    if searchInputSelector
      timer = null
      loadAllOnSearch=()->
        value = $(searchInputSelector).val()
        if (typeof value != 'undefined') and value.trim().length>0
          showLoading()
          loadNext () ->
            if $container.data('completed')
              hideLoading() unless loading
            else
              loadAllOnSearch()
        else
          hideLoading() unless loading


      $(searchInputSelector).keyup (e) ->
        clearTimeout(timer) if timer
        timer = setTimeout(loadAllOnSearch,200)

      $(searchInputSelector).keyup (e) ->
        clearTimeout(timer) if timer
        timer = setTimeout(loadAllOnSearch,1000)


    # add load next items button
    if settings.loadNextButton
      $loadNextButton = $("<button class='#{loadNextItemsCssClass}'>#{loadNextLabel}</button> ").appendTo($buttons)
      $loadNextButton.click (e) ->
        showLoading()
        loadNext () -> hideLoading()

    # add load all items button
    if loadAllButton
      $loadAllButton = $(" <button class='#{loadAllItemsCssClass}' data-toggle='tooltip' title='This might take a while!'>#{loadAllLabel}</button> ").appendTo($buttons)
      $loadAllButton.tooltip();
      $loadAllButton.click () ->
        showLoading()
        loadAll (data) -> hideLoading()
