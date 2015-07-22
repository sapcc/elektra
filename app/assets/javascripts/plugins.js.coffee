$.fn.update = () ->
  $element  = $(this)
  url       = $element.data('updateUrl')
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
 