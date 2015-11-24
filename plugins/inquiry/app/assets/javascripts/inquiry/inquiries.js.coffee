$.fn.loadInquiries = () ->
  this.each () ->
    $element  = $(this)
    # request inquiries via ajax


    $.ajax
      beforeSend: ->
        $element.html('<div class="ajax-load">Loading...</div>')
      complete: ->
        #$element.removeClass('ajax-load')  
        
      url: $element.data('url')
      data:
        container_id: $element.attr('id')
        per_page: ($element.data('per_page') || 3)
        filter: ($element.data('filter') || {})
      dataType: 'script'

$(document).ready ->
  $(".remote_inquiries[data-url]").loadInquiries()     
