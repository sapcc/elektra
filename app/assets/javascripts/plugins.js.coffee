polling_update_url_count = {}
polling_update_interval = 30000

$.fn.update = () ->
  this.each () ->
    $element  = $(this)

    # data-updateUrl is set by server
    url       = $element.data('updateUrl')
    # return if no update url defined
    return this unless url

    polling_update_url_count[url] = (polling_update_url_count[url] || 0) + 1
    count = polling_update_url_count[url]
    return if (count*polling_update_interval)>5*60*1000

    interval  = $element.data('interval') || polling_update_interval

    setTimeout () ->
      $.ajax
        url: url
        # success: (newItem) ->
        #   $newItem = $(newItem)
        #   $element.replaceWith($newItem)
        #   $newItem.update()
    , interval

    return this;
