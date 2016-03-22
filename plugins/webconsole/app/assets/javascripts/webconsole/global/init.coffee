# ------------------------------------------------------------------------------------------
# Init Web Console
# ------------------------------------------------------------------------------------------
$(document).ready ->
  if $('#webconsole-container').length>0 
    WebconsoleContainer.init('#webconsole-container')
    WebconsoleContainer.load()
    
  else if $('[data-trigger="webconsole:open"]').length>0
    $("<div class='webconsole'><div id='webconsole-container' class='popup'/></div>").appendTo('body')  
    WebconsoleContainer.init('#webconsole-container',{
      toolbar: 'on'
      title: 'Web Console'
      buttons: ['reload','close']  
    })  
