# Confirmation Dialog
$ ->
  $.rails.allowAction = (link) ->
    return true unless link.attr('data-confirm')
    $.rails.showConfirmDialog(link) unless link.attr('data-confirming') 
    link.attr('data-confirming','true')
    false 

  $.rails.confirmed = (link) ->
    link.removeAttr('data-confirm')
    link.removeAttr('data-confirming')
    link.trigger('click.rails')

  $.rails.canceled = (link) ->
    link.removeAttr('data-confirming') 


  $.rails.showConfirmDialog = (link) ->
    message = link.attr 'data-confirm'
    html = """
           <div class="modal fade" id="confirmationDialog">
             <div class="modal-dialog">
               <div class="modal-content">
                 <div class="modal-header">
                   <a class="close" data-dismiss="modal">×</a>
                   <h4>#{message}</h4>
                 </div>
                 <div class="modal-footer">
                   <a data-dismiss="modal" class="btn cancel">#{link.data('cancel') || 'Cancel'}</a>
                   <a data-dismiss="modal" class="btn btn-primary confirm">#{link.data('ok') || 'Ok'}</a>
                 </div>
               </div>
             </div>
           </div>
           """
    $html = $(html)
    $html.find('.confirm').on 'click', -> $.rails.confirmed(link)
    $html.find('.cancel').on 'click', -> $.rails.canceled(link)
    $html.modal()



@waitingDialog ||= (($) -> 
  #'use strict'
  
  # Creating modal dialog's DOM
  html = """
      <div class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true" style="padding-top:15%; overflow-y:visible;">
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
  

  show: (title,message, options) ->
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
    $dialog.find('.modal-body').text(message)

    # Adding callbacks
    if typeof settings.onHide is 'function'
      $dialog.off('hidden.bs.modal').on 'hidden.bs.modal', (e) -> settings.onHide.call($dialog)

    # Opening dialog
    $dialog.modal()
    
  showError: (message) ->
    waitingDialog.show("Error", message)
  
  hide: () -> $dialog.modal 'hide'
      
)(jQuery)