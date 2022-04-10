class MoModal
  modal_holder_selector = '#modal-holder'
  modal_selector = '.modal'
  modal_is_loading = false

  loading = """
      <div class="modal loading-dialog" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-sm">
          <div class="modal-content">
            <div class="modal-body"><div class="loading-spinner"></div><div class="loading-text">Loading...</div></div>
          </div>
        </div>
      </div>
      """

  @init= () ->
    $(document).on 'click', 'a[data-modal=true]', -> MoModal.load(this)
    $(document).on 'click', '[data-modal-transition]', -> MoModal.replace(this)
    $(document).on 'ajax:beforeSend',modal_holder_selector+' form[data-inline!="true"]', (event, xhr, settings) -> settings.data += "&modal=true"
    $(document).on 'ajax:success', modal_holder_selector+' form[data-inline!="true"]', handleAjaxSuccess
    $(document).on 'ajax:error', modal_holder_selector+' form[data-inline!="true"]', (event,jqXHR, textStatus, errorThrown) -> showError(jqXHR, textStatus, errorThrown)

  @close= () -> $('#modal-holder').find('.modal').modal('hide')

  @load= (anker)->
    if jQuery.type(anker) == "string"
      location = anker
    else
      $button = $(anker)
      #$button.addClass('loading')
      location = $(anker).attr('href')
      modalSize = $(anker).attr('data-modal-size')

    # do nothing if modal is loading
    return false if modal_is_loading

    # close in case it was open
    MoModal.close()

    #Load modal dialog from server
    InfoDialog.showLoading()
    attr = {modal:true}
    if modalSize && modalSize.length > 0
      attr["modal_size"] = modalSize

    modal_is_loading = true
    $.get(location, attr)
      .error showError
      .done (data, status, xhr)->
        # console.log 'done'
        #$button.removeClass('loading')
        InfoDialog.hideLoading()

        url = xhr.getResponseHeader('Location')

        # got a redirect response
        if url
          # close modal window
          $('#modal-holder').find('.modal').modal('hide')
          window.location = url
        else
          if $('.modal-backdrop').length==0 # prevent multiple overlays on double click
            # open modal with content from ajax response
            $(modal_holder_selector).html(data).find(modal_selector).modal()
            # for the case the response contains a form intialize it
            triggerUpdateEvent()
      .complete () ->
        modal_is_loading = false
    return false

  @replace= (anker) ->
    $(modal_holder_selector).find(modal_selector).find('.modal-body').html('<div class="loading-spinner"></div><div class="loading-text">Loading...</div>')

    lastUrl = window.location.href
    ankerUrl = $(anker).attr('href')

    $.ajax
      dataType: 'html',
      url: ankerUrl,
      data: {modal: true, modal_transition: true},
      error: showError,
      success: (data, textStatus, jqXHR) ->
        $data = $(data)
        $footer = $data.find('.modal-footer')
        if $footer.length>0
          # add back button to footer
          $back = $('<a href="javascript:void(0)" class="btn btn-primary">Back</a>')
          $back.click () -> window.location.href=lastUrl
          $footer.prepend($back)

        $('.modal-backdrop').remove()
        $(modal_holder_selector).find(modal_selector).replaceWith($data)
        $(modal_holder_selector).find(modal_selector).modal()
        #
        # $(modal_holder_selector).find(modal_selector).modal('hide')
        # $(modal_holder_selector).html($data).find(modal_selector).modal()
        triggerUpdateEvent()
    return false

  showError= (jqXHR, textStatus, errorThrown) ->
    # console.log("jqXHR",jqXHR)
    # console.log("textStatus",textStatus)
    # console.log("errorThrown",errorThrown)
    # console.log 'Loading error'
    InfoDialog.hideLoading()
    # restore url -> remove ?overflow=...
    window.restoreOriginStateUrl()
    # show error dialog
    try
      errorMessage = jqXHR.statusText+' ('+jqXHR.status+')'
      details = jqXHR.responseText
    catch e
      errorMessage = errorThrown
      details = null

    InfoDialog.showError(errorMessage,details)

  triggerUpdateEvent= ->
    $modalHolder = $(modal_holder_selector)
    target = {id: $modalHolder.prop('id'), class: $modalHolder.prop('class')}
    # $(document).trigger('modal:contentUpdated',{id: $modalHolder.prop('id'), class: $modalHolder.prop('class')})
    $(document).trigger(type: 'modal:contentUpdated', target: target)

  handleAjaxSuccess= (event, data, status, xhr)->
    url = xhr.getResponseHeader('Location')
    response_type = (xhr.getResponseHeader("content-type") || "")

    if url # url is presented
      # close modal window
      $('#modal-holder').find('.modal').modal('hide')
      # Redirect to url
      window.location = url
    else if response_type.indexOf('javascript') > -1
      # response is javascript
      # Commeted lines as removes the backdrop when sending ajax calls to change the modal content
      # Remove old modal backdrop
      # $('.modal-backdrop').remove()
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

      triggerUpdateEvent()
    return false

$ -> MoModal.init()
