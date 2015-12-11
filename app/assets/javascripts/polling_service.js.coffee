class @PollingService
  selector = null 
  interval = null
   
  update= () ->    
    timestamp = Math.round((new Date().getTime())/ 1000)
        
    $(selector).each () ->
      $element  = $(this)
      # data-updateUrl is set by server
      url       = $element.data('updatePath')

      # return if no update url defined
      return this unless url

      updateInterval = $element.data('updateInterval') || 10
      updateInterval = updateInterval*1000 if updateInterval < 1000
      
      # modulo operation
      shouldUpdate = (timestamp % Math.round(updateInterval/ interval))==0
    
      if shouldUpdate
        # update content
        $.ajax
          url: url,
          dataType: 'html',
          success: ( data, textStatus, jqXHR ) ->
            #exists = $.contains(document.documentElement, $element)
            $element.replaceWith(data)
            
  @init= (options={}) ->
    selector = options["selector"]    
    interval = options["interval"] || 10
    interval = interval*1000 if interval < 1000
    
    # start update with interval
    setInterval update, interval