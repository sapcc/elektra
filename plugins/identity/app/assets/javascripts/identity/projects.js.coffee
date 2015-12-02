(($) ->
  # load content via ajax
  loadContent= (container) ->
    $container  = $(container)

    $.ajax
      beforeSend: ->
        #$container.html('<div class="ajax-load">Loading...</div>')
      complete: ->
        #$container.removeClass('ajax-load')
      url: $container.data('url')
      data:
        container_id: $container.attr('id')
        per_page: ($container.data('per_page') || 3)
        filter: ($container.data('filter') || {})
      dataType: 'script'
  
  # available methods  
  methods = 
    init: ->
      console.log 'init remote projects'
      loadContent(this)
      
    reload: ->
      loadContent(this)

    update: (params = {}) ->
      $elem = $(this)
      for key, value of params
        $elem.data(key,value) if $elem.attr("data-#{key}") 
    
    get: (key) -> 
      $(this).data(key)    

  # plugin definition
  $.fn.projectsWidget = (methodOrOptions) ->
    if methods[methodOrOptions]
      options = Array.prototype.slice.call( arguments, 1 )
      if this.length>1
        this.each () -> methods[ methodOrOptions ].apply( this, options)
      else
        methods[ methodOrOptions ].apply( this, options)    
        
    else if (typeof methodOrOptions == 'object' || !methodOrOptions )
      console.log('init',this.length)
      this.each () -> methods.init.apply(this)
    else
      $.error( 'Method ' +  methodOrOptions + ' does not exist on jQuery.tooltip' )
  
)(jQuery)       

$(document).ready -> $("[data-widget=projects]").projectsWidget()  