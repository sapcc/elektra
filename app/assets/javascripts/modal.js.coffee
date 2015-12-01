class @MoModal 
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
    
  @init= () ->
    $(document).on 'click', 'a[data-modal=true]', -> 
      MoModal.load(this)  
    $(document).on 'ajax:beforeSend','form[data-modal=true]', (event, xhr, settings) -> 
      settings.data += "&modal=true"
    $(document).on 'ajax:success', 'form[data-modal=true]', handleAjaxSuccess
      
  @load= (anker)->
    $button = $(anker)
    
    #$button.addClass('loading')
    location = $(anker).attr('href')
    #Load modal dialog from server

    InfoDialog.showLoading()
    
    $.get location, {modal:true}, (data, status, xhr)->
      #$button.removeClass('loading')
      InfoDialog.hideLoading()
      
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
        
    return false
  

  handleAjaxSuccess= (event, data, status, xhr)->  
      url = xhr.getResponseHeader('Location')
      response_type = (xhr.getResponseHeader("content-type") || "")
            
      if url # url is presented
        # Redirect to url
        window.location = url
      else if response_type.indexOf('javascript') > -1
        # response is javascript
        # Remove old modal backdrop
        $('.modal-backdrop').remove()
      else
        # assume response is a html
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
      return false

$ -> MoModal.init()           