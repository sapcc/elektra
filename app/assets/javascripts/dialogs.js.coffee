# Custom Confirmation Dialog
$ ->
  $.rails.allowAction = (link) ->
    # return if link has been already confirmed
    return true unless link.attr('data-confirm')
    # open custom confirmation dialog
    $.rails.showConfirmDialog(link)
    # hold on
    false

  # action has been confirmed
  $.rails.confirmed = (link) ->
    # remove confirm attribute
    link.removeAttr('data-confirm')
    # fire confirm:complete event
    $.rails.fire(link, 'confirm:complete', true)
    # fire click event
    link.trigger('click.rails')


  # custom confirmation dialog
  $.rails.showConfirmDialog = (link) ->
    # do not show a new dialog if an existing dialog for this link is already presented
    return false if link.attr('data-confirming')
    # mark link as confirming -> means the dialog is active
    link.attr('data-confirming','true')
    confirmTerm = link.attr('data-confirm-term')

    message = $("<div>").text(link.attr('data-confirm')).html();
    if link.attr('data-icon')!='false'
      message = '<i class="confirm-icon fa fa-fw fa-exclamation-triangle"></i>'+message

    html = """
           <div class="modal fade" style="padding-top:15%; overflow-y:visible;">
             <div class="modal-dialog">
               <div class="modal-content">
                 <div class="modal-header">
                   <a class="close" data-dismiss="modal">×</a>
                   <h4>#{message}</h4>
                 </div>

                 <div class="modal-footer">
                   <a data-dismiss="modal" class="btn">#{link.data('cancel') || 'Cancel'}</a>
                   <button data-dismiss="modal" class="btn btn-primary confirm">#{link.data('ok') || 'Ok'}</button>
                 </div>
               </div>
             </div>
           </div>
           """
    $html = $(html)
    $confirmButton = $html.find('button.confirm')
    $confirmButton.click () -> $.rails.confirmed(link)

    if confirmTerm
      label = $("<div>").text(link.attr("data-confirm-term-label")).html() || 'Please confirm "'+confirmTerm+'"'
      $modalBody = $('<div class="modal-body"></div>')
      $confirmSection = $('<div class="confirm-term form-group string required"><label class="string required">'+label+' </label></div>').appendTo($modalBody)
      $confirmField = $('<input type="text"/>').appendTo($confirmSection)

      $confirmButton.attr('disabled',true)

      $confirmField.keyup (e) ->
        if this.value==confirmTerm
          $confirmButton.attr('disabled',false)
        else
          $confirmButton.attr('disabled',true)

      $html.find('.modal-header').after($modalBody)


    # dialog is beeing closed
    $html.on 'hidden.bs.modal', (e) ->
      # remove confirming mark
      link.removeAttr('data-confirming')
      
      # https://github.com/twbs/bootstrap/issues/15260
      # when closing the confirm dialog when the main modal view still open removes the class "modal-open" which prevent the modal view to be scrolled
      # check if the main modal view still open
      if $('#mainModal.modal.in').length > 0
        # set back the class "modal-open" back to the body so the main modal view can still be used
        $("body").addClass("modal-open");


    $html.modal()

$ ->
  # handle confirm:complete events on links
  $('*[data-confirm]').on 'confirm:complete', (e,response) ->
    try
      if response
        link = e.currentTarget
        confirmed_callback = link?.getAttribute('data-confirmed')?.replace('this','link')
        # execute confirmed callback if defined (<a data-confirmed="alert('confirmed')"/>)
        eval(confirmed_callback) if confirmed_callback
    catch

    response


class @InfoDialog
  loading = """
      <div class="modal " data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-sm">
          <div class="modal-content">
            <div class="modal-body"><div class="loading-spinner"></div><div class="loading-text">Loading...</div></div>
          </div>
        </div>
      </div>
      """
  $ajaxLoader = $(loading)

  # Creating modal dialog's DOM
  html = """
      <div class="modal fade" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true" style="padding-top:15%; overflow-y:visible;">
        <div class="modal-dialog modal-m">
          <div class="modal-content">
            <div class="modal-header"><h3 style="margin:0;"></h3></div>
            <div class="modal-body">

            </div>
            <div class="modal-footer">
              <button class="btn btn-default" type="button" data-dismiss="modal", aria-label="Close">Close</button>
            </div>
          </div>
        </div>
      </div>
      """
  $dialog = $(html)

  # class method show
  @show: (title,message, options) ->
    # Assigning defaults
    options ||= {}
    message ||= 'Loading'

    settings = $.extend
      dialogSize: 'm'
      progressType: ''
      onHide: null # This callback runs after the dialog was hidden
    , options

    # Configuring dialog
    $dialog.find('.modal-dialog').attr('class', 'modal-dialog').addClass('modal-' + settings.dialogSize)
    $dialog.find('.progress-bar').attr('class', 'progress-bar')
    $dialog.find('.progress-bar').addClass('progress-bar-' + settings.progressType) if settings.progressType
    $dialog.find('h3').text(title)

    if $(message).find('.modal-body').length > 0
      $dialog.find('.modal-body').html($(message).find('.modal-body').html())
    else
      $dialog.find('.modal-body').html(message)

    # Adding callbacks
    if typeof settings.onHide is 'function'
      $dialog.off('hidden.bs.modal').on 'hidden.bs.modal', (e) -> settings.onHide.call($dialog)

    # Opening dialog
    $dialog.modal()

  # class method
  @showError: (message, details=null) ->
    error_wrapper = '<div>'
    error_wrapper += '<p>'+message+'</p>'

    if details
      error_wrapper += '<p><a href="#", data-toggle="show-error-details">Show error details <i class="fa fa-caret-down"></i></a></p>'
      error_wrapper += '<div class="scrollable-text error-details-area hide">'+details+'</div>'

    error_wrapper += '</div>'

    InfoDialog.show("Application Error", error_wrapper, {dialogSize: 'lg'})
    if details
      setTimeout(init_error_details,500)

  # class method
  @showNotice: (message) ->
    InfoDialog.show("Notice", message)

  # class method
  @showInfo: (message) ->
    InfoDialog.show("Info", message)

  # class method
  @hide: () -> $dialog.modal 'hide'

  @showLoading: () -> $ajaxLoader.modal 'show'
  @hideLoading: () -> $ajaxLoader.modal 'hide'
