$ ->
  modal_holder_selector = '#modal-holder'
  modal_selector = '.modal'
  
  loading = """
      <div class="modal " data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-m">
          <div class="modal-content">
            <div class="modal-body">Loading...</div>
          </div>
        </div>
      </div>
      """
    
  $(document).on 'click', 'a[data-modal=true]', ->
    location = $(this).attr('href')
    #Load modal dialog from server
    
    $(modal_holder_selector).html(loading).find(modal_selector).modal()
    
    $.get location, (data)->
      console.log('done')
      $('.modal-backdrop').remove()
      if $('.modal-backdrop').length==0 # prevent multiple overlays on double click 
        # open modal with content from ajax response
        $(modal_holder_selector).html(data).
        find(modal_selector).modal()
    false

  $(document).on 'ajax:success',
    'form[data-modal=true]', (event, data, status, xhr)->
      url = xhr.getResponseHeader('Location')
      if url
        # Redirect to url
        window.location = url
      else
        # Remove old modal backdrop
        $('.modal-backdrop').remove()

        # Replace old modal with new one
        $(modal_holder_selector).html(data).
        find(modal_selector).modal()
      false