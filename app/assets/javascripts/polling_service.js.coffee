# this class implements the polling service
class @PollingService
  selector = null 
  interval = null
   
  updateElement= (element) ->
    $element = $(element)
    url = $element.data('updatePath')
    return unless url
         
    $.ajax
      url: url,
      dataType: 'html',
      data: {'polling_service': true},
      success: ( data, textStatus, jqXHR ) ->
        # try to get loacation from response header 
        redirectTo = jqXHR.getResponseHeader('Location')
        # response is a redirect
        if redirectTo 
          # redirect url is equal to auth path
          if redirectTo.indexOf('/auth/login/')>-1
            # just reload to avoid redirect to a no layout page after login
            window.location.reload()
          else
            # redirect to the redirectTo url
            window.location = redirectTo
        else
          # no redirect -> replace content with html from response
          #exists = $.contains(document.documentElement, $element)
          $element.replaceWith(data)   
          
     
  # update method which is called periodically 
  update= () ->    
    # get current timestamp
    timestamp = Math.round((new Date().getTime())/ 1000)
    
    # for each element found by selector do
    $(selector).each () ->
      $element  = $(this)

      # element's own update interval
      updateInterval = $element.data('updateInterval') || 10
      updateInterval = updateInterval*1000 if updateInterval < 1000
      
      # modulo operation: rest of current timestamp divided by element's interval should be zero
      shouldUpdate = (timestamp % Math.round(updateInterval/ interval))==0
      
      updateElement($element) if shouldUpdate
          
            
  # initialize the service          
  @init= (options={}) ->
    # selector is a string which identifies DOM elements to be updated
    selector = options["selector"]    
    
    # update elements immediately if they have the corresponding attribute
    $("#{selector}[data-update-immediately='true']").each () -> updateElement(this)
    
    
    # Interval in seconds or milliseconds between polling calls.
    # The polling service runs regularly and tries to update all the elements found by selector.
    # Each element (found by selector) can define its own interval. The element is only updated 
    # if its interval is correlated with the polling interval.
    interval = options["interval"] || 10
    interval = interval*1000 if interval < 1000
    
    # start update with interval
    setInterval update, interval

  # fire an update event. All elements which data-update-path matches the given name will be updated!
  # For example, update('inquiries') will update data-update-path='inquiriy/inquiries/list'.    
  @update= (name) ->
    $("*[data-update-path*='#{name}']").each () -> updateElement(this)
