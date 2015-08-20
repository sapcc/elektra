$.fn.update = () ->
  this.each () ->    
    $element  = $(this)

    # data-updateUrl is set by server
    url       = $element.data('updateUrl')
    # return if no update url defined
    return this unless url
    interval  = $element.data('interval') || 5000
  
    setTimeout () ->
      $.ajax
        url: url
        # success: (newItem) ->
        #   $newItem = $(newItem)
        #   $element.replaceWith($newItem)
        #   $newItem.update()        
    , interval

    return this;
 