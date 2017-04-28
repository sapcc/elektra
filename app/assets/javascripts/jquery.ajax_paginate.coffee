# jQuery plugin
jQuery.fn.ajaxPaginate= ( options ) ->
  # default values for all paginate plugins
  defaults =
    listSelector: null,
    loadNextButton: true
    loadAllButton: true
    loadNextLabel: 'Load Next Items'
    loadAllLabel: 'Load All Items'
    loadNextItemsCssClass: 'btn btn-success'
    loadAllItemsCssClass: 'btn btn-primary'

  # merge defaults and options
  settings = $.extend( {}, defaults, options )

  # for each element found by selector
  this.each () ->
    $container = $(this)
    # define spinner element
    $spinner = $('<span class="spinner"></span>').appendTo($container).hide()
    # define buttons container
    $buttons = $('<div></div>').appendTo($container)

    # default only for the current pagination (this)
    listSelector = $container.data('listSelector') || settings.listSelector
    loadNextButton = if typeof $container.data('nextButton') != 'undefined' then $container.data('nextButton') else true
    loadAllButton = if typeof $container.data('allButton') != 'undefined' then $container.data('allButton') else false
    loadNextLabel = $container.data('nextLabel') || settings.loadNextLabel
    loadAllLabel = $container.data('allLabel') || settings.loadAllLabel
    loadNextItemsCssClass = $container.data('nextCssClass') || settings.loadNextItemsCssClass
    loadAllItemsCssClass = $container.data('allCssClass') || settings.loadAllItemsCssClass
    loadAllMode = false

    # show loading indicator (hide buttons)
    showLoad=() -> $buttons.fadeOut 'slow', () -> $spinner.show()
    # hide loading indicator and show buttons
    hideLoad=() -> $spinner.hide(); $buttons.fadeIn('slow')

    loadNext=(callback) ->
      # get next page from container data
      nextPage = $container.data('currentPage')+1
      # get last marker
      marker = $($('*[data-marker-id]').last()).data('markerId')
      # load next items via ajax
      $.get '', {page: nextPage, marker: marker}, (data) ->
        # update the list
        $(listSelector).append(data)
        # update the page count
        $container.data('currentPage',nextPage)
        # call the callback method
        callback(data) if callback

    loadAll=(callback) ->
      # load next items
      loadNext (data) ->
        # if items are empty hide the loading indicator and return
        if (typeof data == 'undefined') or data.trim().length==0
          callback() if callback
        else
          # there are items, so call loadAll method again and get next items
          loadAll(callback)

    # initial page counter value
    $container.data('currentPage',1)

    # add load next items button
    if settings.loadNextButton
      $loadNextButton = $("<button class='#{loadNextItemsCssClass}'>#{loadNextLabel}</button> ").appendTo($buttons)
      $loadNextButton.click (e) ->
        showLoad()
        loadNext (data) ->
          if (typeof data == 'undefined') or data.trim().length==0
            $spinner.hide()
          else
            hideLoad()

    # add load all items button        
    if settings.loadAllButton
      $buttons.append('&nbsp;')
      $loadAllButton = $(" <button class='#{loadAllItemsCssClass}'>#{loadAllLabel}</button> ").appendTo($buttons)
      $loadAllButton.click () ->
        showLoad()
        loadAll () -> $spinner.hide()
