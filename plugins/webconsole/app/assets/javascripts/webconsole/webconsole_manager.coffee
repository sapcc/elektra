class @WebconsoleManager
  webcli_loaded = false

  # add required dom elements to body
  @createDomStructure= () ->
    $('body').append('
      <div class="webconsole">
        <div id="fixed-webconsole">
          <div class="toolbar">
            Web Console
            <div class="main-buttons">
              <a href="javascript:void(0)" data-trigger="webconsole:reload">
                <i class="fa fa-refresh"/>
              </a> 
              <a href="javascript:void(0)" class="last" data-trigger="webconsole:close">
                <i class="fa fa-chevron-down"/>
              </a>
            </div>
          </div>
          <div id="webconsole-container"/>
        </div>
      </div>')

  # load js scripts and cache
  cachedScript= ( url, options ) ->
    # Allow user to set any option except for dataType, cache, and url
    options = $.extend( options || {}, {
      dataType: "script",
      cache: true,
      url: url
    })
 
    # Use $.ajax() since it is more flexible than $.getScript
    # Return the jqXHR object so we can chain callbacks
    $.ajax( options );
  
  # load credentials for current user (token, identity and webcli endpoints)
  loadCredentials= () ->
    $.ajax
      dataType: "json"
      cache: false
      url: "/#{window.scoped_domain_id}/#{window.scoped_project_id}/webconsole/credentials"

  @reloadWebcli= () ->
   # set loading message
    $("#webconsole-container").html("<div id='loading-hint'><span class='info-text'>Loading web console</span><span class='spinner'></span></div>");
    console.log('Webconsole opend')

    # load token and endpoints 
    loadCredentials().success ( credentials, textStatus, jqXHR ) ->
      console.log 'success2', credentials
      
      # load lib
      $.when(
          cachedScript("#{credentials.webcli_endpoint}/js/hterm.js"),
          cachedScript("#{credentials.webcli_endpoint}/js/gotty.js"),
          $.Deferred ( deferred ) -> $( deferred.resolve )
          
      ).done () ->
        # success
        console.log 'hterm loaded'
        console.log 'gotty loaded'
        
        # load webcli
        $.ajax
          url: "#{credentials.webcli_endpoint}/auth"
          xhrFields: { withCredentials: true }
          beforeSend: (request) -> request.setRequestHeader('X-Auth-Token', credentials.token)
          dataType: 'json'
          success: ( data ) -> 
            # success -> add terminal div to container
            $("#webconsole-container").html('<div id="terminal"/>')
            # open socket
            openCLIWebsocket data.url, [credentials.token, credentials.identity_url], () -> $('#loading-hint').remove()
            webcli_loaded = true
          error: (xhr, bleep, error) -> console.log('error: ' + error)
        
  # open webconsole    
  @open= (callback) ->
    # Open console container
    $("#fixed-webconsole").slideDown 'slow', () ->
      WebconsoleManager.reloadWebcli() unless webcli_loaded
      callback() if callback
      
  
  @close= (callback) ->
    $("#fixed-webconsole").slideUp 'slow', () -> 
      console.log('Webconsole closed')
      callback() if callback