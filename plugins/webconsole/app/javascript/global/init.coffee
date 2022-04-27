# ------------------------------------------------------------------------------------------
# Init Web Console
# ------------------------------------------------------------------------------------------
$(document).ready ->

  # stand alone webconsole page
  if $('#webconsole-container').length>0
    $( "#webconsole-container" ).wrap( "<div class='webconsole'></div>" );
    WebconsoleContainer.init('#webconsole-container',{})
    WebconsoleContainer.load()


  # slide-in webconsole panel
  else if $('[data-trigger="webconsole:open"]').length>0
    $("<div class='webconsole popup'><div id='webconsole-container'/></div>").appendTo('body')
    WebconsoleContainer.init('#webconsole-container',{
      toolbar: 'on'
      title: 'Web Shell'
      buttons: ['help','reload','close']
    })

  $('[data-toggle="tooltip"]').tooltip(delay: { "show": 700 }, trigger: "hover")
