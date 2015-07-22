$ ->
  modal_holder_selector = '#modal-holder'
  modal_selector = '.modal'
  
  loading = """
      <div class="modal " data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-sm">
          <div class="modal-content">
            <div class="modal-body"><div class="loading-spinner"></div><div class="loading-text">Loading...</div></div>
          </div>
        </div>
      </div>
      """
    
  $(document).on 'click', 'a[data-modal=true]', ->
    $button = $(this)
    
    $button.addClass('loading')
    location = $(this).attr('href')
    #Load modal dialog from server

    #InfoDialog.showLoading()
    
    $.get location, {modal:true}, (data, status, xhr)->
      $button.removeClass('loading')
      #InfoDialog.hideLoading()
      
      url = xhr.getResponseHeader('Location')
      
      # got a redirect response
      if url
        window.location = url
      else  
        if $('.modal-backdrop').length==0 # prevent multiple overlays on double click
          # open modal with content from ajax response
          $(modal_holder_selector).html(data).
          find(modal_selector).modal()
          # for the case the response contains a form intialize it
          Dashboard.initForm()
        
    false
    
  $(document).on 'ajax:beforeSend', 
    'form[data-modal=true]', (event, xhr, settings) ->
      settings.data += "&modal=true"    

  $(document).on 'ajax:success',
    'form[data-modal=true]', (event, data, status, xhr)->  
      url = xhr.getResponseHeader('Location')
      
      if url
        # Redirect to url
        window.location = url
      else
        # modal has the fade effect 
        if $($(modal_holder_selector).find(modal_selector)).hasClass('fade')
          # replace content of old modal
          $oldModal = $(modal_holder_selector)
          $newContent = $(data)
          $oldModal.find(selector).replaceWith( $newContent.find(selector) ) for selector in ['.modal-body','.modal-footer']
        else  
          # Remove old modal backdrop
          $('.modal-backdrop').remove()
          # Replace old modal with new one
          $(modal_holder_selector).html(data).find(modal_selector).modal()
        Dashboard.initForm()  
      false