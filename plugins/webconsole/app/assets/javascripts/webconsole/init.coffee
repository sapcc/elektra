# ------------------------------------------------------------------------------------------
# Init Web Console
# ------------------------------------------------------------------------------------------
$(document).ready ->
  WebconsoleManager.createDomStructure()
  
  $('[data-trigger="webconsole:open"]').click (e) ->
    e.preventDefault()
    if $(this).hasClass('active')
      $(this).removeClass('active')
      WebconsoleManager.close()  
    else
      $(this).addClass("active")
      WebconsoleManager.open()
     
  $('[data-trigger="webconsole:reload"]').click (e) ->
    e.preventDefault()
    WebconsoleManager.reloadWebcli()
        
  $('[data-trigger="webconsole:close"]').click (e) ->
    e.preventDefault()
    WebconsoleManager.close () ->
      $('[data-trigger="webconsole:open"]').removeClass("active");  
      
  
  if plugin_name
    WebconsoleManager.open()    
