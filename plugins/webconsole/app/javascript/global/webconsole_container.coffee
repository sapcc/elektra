class WebconsoleContainer
  unless Storage is "undefined"
    # save information from local storage in class variable.
    webconsoleHelpSeen = localStorage.getItem("webconsoleHelpSeen")
    
  defaults =
    toolbarCssClass:    'toolbar'
    buttonsCssClass:    'main-buttons'
    holderCssClass:     'webconsole-holder'
    helpCssClass:       'webconsole-help'
    loadingText:        'Loading web shell'
    toolbar:            'on'
    title:              'Web Shell'
    buttons:            null #['help','reload','close', 'fullscreen']
    effect:             'slide'
    height:             null #'viewport'
    closeIcon:          'fa fa-close'
    helpIcon:           'fa fa-question-circle'
    reloadIcon:         'fa fa-refresh'
    fullscreenIcon:     'fa fa-expand'
    compressIcon:       'fa fa-compress'
    closeText:          'Close web shell'
    helpText:           'Show help'
    reloadText:         'Reload shell'
    fullscreenText:     'Toggle full width'

  # create toolbar, buttons and console holder
  createDomStructure=($container, settings) ->
    if settings.toolbar=='on' # toolbar is on
      # add toolbar to container
      $toolbar = $("<div class='#{settings.toolbarCssClass}'/>").prependTo($container.parent())

      if settings.title # title exists
        # add title to toolbar
        $toolbar.append(settings.title)
      if settings.buttons and settings.buttons.length>0 # buttons given
        # add buttons container to toolbar
        $buttons = $("<div class='#{settings.buttonsCssClass}'/>").appendTo($toolbar)

        # create and add each button to buttons container
        for button, i in settings.buttons
          $buttons.append("<a href='#' data-trigger='webconsole:#{button}' data-toggle='tooltip' title='#{settings[button+'Text']}'><i class='#{settings[button+'Icon']}'/></a>")

    # add webconsole holder to container
    # and return this holder
    $("<div class='#{settings.holderCssClass}'/>").appendTo($container)

  # adds help container to console holder
  addHelpContainer= ($container, settings) ->
    # create a container div for help content
    $helpContainer = $container.find(".#{settings.helpCssClass}")
    if $helpContainer.length==0
      $helpContainer = $("<div class='#{settings.helpCssClass}'></div>").appendTo($container).hide()

      # create a container div for help text and show it
      $helpContent = $("<div class='#{settings.helpCssClass}-content'></div>").appendTo($helpContainer)

      # open help container unless already seen  
      $helpContainer.animate({width:'toggle'},'400px') unless webconsoleHelpSeen
        
      # set help button to active
      $('[data-trigger="webconsole:help"]').addClass('active')

      # create toggle button and bind click event
      $("<a href='#' class='toggle'><i class='fa fa-close'></i></a>").prependTo($helpContainer).click (e) ->
        $helpContainer.animate({width:'toggle'},'400px')
        $('[data-trigger="webconsole:help"]').toggleClass('active')
        # save information already seen in local storage
        localStorage.setItem("webconsoleHelpSeen",true)


      # set height
      # $webconsoleHolder = $container.find(".#{settings.holderCssClass}")
      # height = $webconsoleHolder.height()
      $toolbar = $container.find(".#{settings.toolbarCssClass}")
      top = if $toolbar.length>0 then $toolbar.position().top+$toolbar.outerHeight(true) else 0
      # $helpContainer.css(top: top, height: height)
      $helpContainer.css(top: top)
    else
      $helpContent = $helpContainer.find(".#{settings.helpCssClass}-content")

    $helpContent

  # load credentials for current user (token, identity and webcli endpoints)
  loadWebconsoleData= (settings ) ->
    # console.log 'loadWebconsoleData', settings
    path = window.location.pathname
    path = path.substr(1) if path.charAt(0)=='/'
    arr = path.split('/')
    scope = "#{arr[0]}/#{arr[1]}"
    #
    # console.log 'path', path
    # console.log 'scope', scope
    # console.log "lastIndexOf('#{scope}')", path.lastIndexOf(scope)
    #
    options = {
      dataType: 'json',
      type: 'GET',
      cache: false,
      url: "/#{scope}/webconsole/current-context"
    }
    $.ajax( options );

  @init= (containerSelector, settings={}) ->        
    @$container = $(containerSelector)
    @settings   = $.extend {}, defaults, @$container.data(), settings
    @$holder    = createDomStructure(@$container, @settings)

    height = @settings['height']
    if height
      height = $(document).height()-@$container.offset().top-$('.footer').outerHeight(true)
      height = 500 if !height or height<500
      @$container.find(".#{@settings.holderCssClass}").css(height: height)

      # @$container.css(height: height)


    $('[data-trigger="webconsole:open"]').click (e) ->
      e.preventDefault()
      if $(this).hasClass('active')
        $(this).removeClass('active')
        WebconsoleContainer.close()
      else
        $(this).addClass("active")
        WebconsoleContainer.open()

    $('[data-trigger="webconsole:reload"]').click (e) ->
      e.preventDefault()
      WebconsoleContainer.reload()

    $('[data-trigger="webconsole:help"]').click (e) =>
      e.preventDefault()
      @$container.find(".#{@settings.helpCssClass}").animate({width:'toggle'},'400px')
      $(e.currentTarget).toggleClass('active')

    $('[data-trigger="webconsole:close"]').click (e) ->
      e.preventDefault()
      WebconsoleContainer.close () ->
        $('[data-trigger="webconsole:open"]').removeClass("active")

    $('[data-trigger="webconsole:fullscreen"]').click (e) =>
      e.preventDefault()
      icon = $(e.currentTarget).find(".fa")

      if icon.hasClass("#{@settings.fullscreenIcon}")
        icon.removeClass("#{@settings.fullscreenIcon}")
        icon.addClass("#{@settings.compressIcon}")
      else
        icon.removeClass("#{@settings.compressIcon}")
        icon.addClass("#{@settings.fullscreenIcon}")

      WebconsoleContainer.toogleFullscreen()




  @open= (callback) ->
    # Open console container
    @$container.parent().slideDown 'slow', () ->
      WebconsoleContainer.load()
      callback() if callback

  @close= (callback) ->
    @$container.parent().slideUp 'slow', () ->
      callback() if callback

  @toogleFullscreen= (callback) ->
    $parentContainer = @$container.parent()

    new_width = $parentContainer.data('width') || $( window ).width()
    new_left = $parentContainer.data('left') || -$parentContainer.offset().left

    $parentContainer.data('width',$parentContainer.width())
    $parentContainer.data('left', if new_left!=0 then 0 else false)

    @$container.parent().css(position: 'relative').animate({
      width: new_width,
      left: new_left
    })

  @reload= () ->
    @load(true)

  @load= (reload=false) ->
    if @loaded && reload==false
      return

    # bind this to self
    self = this
    # create loading element
    $loadingHint = $("<div class='loading-hint'><span class='info-text'>#{@settings.loadingText}</span><span class='spinner'></span></div>")
    # set holder's content to loading
    @$holder.html($loadingHint)

    $loadingHint.append('<span class="status info-text">0%</span>')

    # load token and endpoints
    loadWebconsoleData(@settings)
      .error (jqXHR, textStatus, errorThrown ) ->
        redirectTo = jqXHR.getResponseHeader('Location')
        # response is a redirect
        if redirectTo && redirectTo.indexOf('/auth/login/')>-1
          # just reload to avoid redirect to a no layout page after login
          window.location.reload()

      .success ( context, textStatus, jqXHR ) ->
        $loadingHint.find('.status').text('20%')

        # define function which implements the webconsole load procedure
        loadConsole = () ->
          $loadingHint.find('.status').text('60%')

          # success
          # load webcli
          $.ajax
            url: "#{context.webcli_endpoint}/auth/#{context.user_name}"
            beforeSend: (request) -> 
              request.setRequestHeader('X-Auth-Token', context.token)
              request.setRequestHeader('X-OS-Region', context.region)
            dataType: 'json'
            success: ( data ) ->
              $loadingHint.find('.status').text('80%')
              # success -> add terminal div to container
              $cliContent = $("<iframe id='webcli-content' src='#{data.url}' height='100%' width='100%' />")
              
              self.$holder.append($cliContent)

              if context.help_html
                $helpContainer = addHelpContainer(self.$container, self.settings)
                $helpContainer.html(context.help_html)

              $loadingHint.remove()


              self.loaded = true
            error: (xhr, bleep, error) -> 
              $loadingHint.html("<div class='info-text'>An error has occurred while trying to load your shell. Please try again later. The error was: <br />#{xhr.status} - #{error}</div>")



        loadConsole()

window.WebconsoleContainer = WebconsoleContainer