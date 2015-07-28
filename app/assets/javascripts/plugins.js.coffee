$.fn.update = () ->
  $element  = $(this)
  # data-updateUrl is set by server
  url       = $element.data('updateUrl')
  # return if no update url defined
  return this unless url
  interval  = $element.data('interval') || 5000
  
  setTimeout () ->
    $.ajax
      url: url
      success: (newItem) ->
        $element.replaceWith(newItem)
        $(newItem).update()
  , interval

  return this;
 