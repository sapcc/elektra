# jQuery plugin
jQuery.fn.ajaxPaginate= ( options ) ->
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
    $spinner = $('<span class="spinner"></span>').appendTo($container).hide()
    $buttons = $('<div></div>').appendTo($container)

    listSelector = $container.data('listSelector') || settings.listSelector
    loadNextButton = if typeof $container.data('nextButton') != 'undefined' then $container.data('nextButton') else true
    loadAllButton = if typeof $container.data('allButton') != 'undefined' then $container.data('allButton') else false
    loadNextLabel = $container.data('nextLabel') || settings.loadNextLabel
    loadAllLabel = $container.data('allLabel') || settings.loadAllLabel
    loadNextItemsCssClass = $container.data('nextCssClass') || settings.loadNextItemsCssClass
    loadAllItemsCssClass = $container.data('allCssClass') || settings.loadAllItemsCssClass
    loadAllMode = false

    showLoad=() -> $buttons.fadeOut 'slow', () -> $spinner.show()
    hideLoad=() -> $spinner.hide(); $buttons.fadeIn('slow')

    loadNext=(callback) ->
      nextPage = $container.data('currentPage')+1
      marker = $($('*[data-marker-id]').last()).data('markerId')
      $.get '', {page: nextPage, marker: marker}, (data) ->
        $(listSelector).append(data)
        $container.data('currentPage',nextPage)
        #$(searchableSelector).searchable('update') if searchableSelector
        callback(data) if callback

    loadAll=(callback) ->
      loadNext (data) ->
        if (typeof data == 'undefined') or data.trim().length==0
          callback() if callback
        else
          loadAll(callback)

    $container.data('currentPage',1)
    #$($('*[data-marker-id]').last()).data('markerId')

    if settings.loadNextButton
      $loadNextButton = $("<button class='#{loadNextItemsCssClass}'>#{loadNextLabel}</button> ").appendTo($buttons)
      $loadNextButton.click (e) ->
        showLoad()
        loadNext (data) ->
          if (typeof data == 'undefined') or data.trim().length==0
            $spinner.hide()
          else
            hideLoad()

    if settings.loadAllButton
      $buttons.append('&nbsp;')
      $loadAllButton = $(" <button class='#{loadAllItemsCssClass}'>#{loadAllLabel}</button> ").appendTo($buttons)
      $loadAllButton.click () ->
        showLoad()
        loadAll () -> $spinner.hide()
