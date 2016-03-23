# ------------------------------------------------------------------------------------------
# Init Web Console
# ------------------------------------------------------------------------------------------
$(document).ready ->

  # stand alone webconsole page
  if $('#webconsole-container').length>0
    WebconsoleContainer.init('#webconsole-container',{
      toolbar: 'on'
      title: 'Web Console'
      buttons: ['help','reload']
    })
    WebconsoleContainer.load()

  # slide-in webconsole panel
  else if $('[data-trigger="webconsole:open"]').length>0
    $("<div class='webconsole popup'><div id='webconsole-container'/></div>").appendTo('body')
    WebconsoleContainer.init('#webconsole-container',{
      toolbar: 'on'
      title: 'Web Console'
      buttons: ['help','reload','close']
    })
