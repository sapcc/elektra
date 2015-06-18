$ ->
  $.rails.allowAction = (link) ->
    return true unless link.attr('data-confirm')
    $.rails.showConfirmDialog(link) 
    false 

  $.rails.confirmed = (link) ->
    link.removeAttr('data-confirm')
    link.trigger('click.rails')

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
                   <a data-dismiss="modal" class="btn">#{link.data('cancel') || 'Cancel'}</a>
                   <a data-dismiss="modal" class="btn btn-primary confirm">#{link.data('ok') || 'Ok'}</a>
                 </div>
               </div>
             </div>
           </div>
           """
    $html = $(html)
    $html.find('.confirm').on 'click', -> $.rails.confirmed(link)
    $html.modal()
    $('#confirmationDialog .confirm').on 'click', -> $.rails.confirmed(link)