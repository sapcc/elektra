class @WebconsoleContainer
  defaults =
    scopedDomainId:     window.scopedDomainId
    scopedDomainFid:     window.scopedDomainFid
    scopedProjectId:    window.scopedProjectId
    scopedProjectFid:    window.scopedProjectFid
    toolbarCssClass:    'toolbar'
    buttonsCssClass:    'main-buttons'
    holderCssClass:     'webconsole-holder'
    helpCssClass:       'webconsole-help'
    loadingText:        'Loading web console'
    pluginName:        null
    toolbar:            'on'
    title:              'Web Console'
    buttons:            null #['help','reload','close']
    effect:             'slide'
    height:             null #'viewport'
    closeIcon:          'fa fa-close'
    helpIcon:           'fa fa-question-circle'
    reloadIcon:         'fa fa-refresh'

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
          $buttons.append("<a href='#' data-trigger='webconsole:#{button}'><i class='#{settings[button+'Icon']}'/></a>")

    # add webconsole holder to container
    # and return this holder
    $("<div class='#{settings.holderCssClass}'/>").appendTo($container)

  # adds help container to console holder
  addHelpContainer= ($container, settings) ->
    # create a container div for help content
    $helpContainer = $("<div class='#{settings.helpCssClass}'></div>").appendTo($container).hide()
    # create a container div for help text and show it
    $helpContent = $("<div class='#{settings.helpCssClass}-content'></div>").appendTo($helpContainer)
    $helpContainer.animate({width:'toggle'},'400px')
    # set help button to active
    $('[data-trigger="webconsole:help"]').addClass('active')

    # create toggle button and bind click event
    $("<a href='#' class='toggle'><i class='fa fa-close'></i></a>").prependTo($helpContainer).click (e) ->
      $helpContainer.animate({width:'toggle'},'400px')
      $('[data-trigger="webconsole:help"]').toggleClass('active')


    # set height
    # $webconsoleHolder = $container.find(".#{settings.holderCssClass}")
    # height = $webconsoleHolder.height()
    $toolbar = $container.find(".#{settings.toolbarCssClass}")
    top = if $toolbar.length>0 then $toolbar.position().top+$toolbar.outerHeight(true) else 0
    # $helpContainer.css(top: top, height: height)
    $helpContainer.css(top: top)
    $helpContent

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
  loadWebconsoleData= (settings ) ->
    # console.log 'loadWebconsoleData', settings
    options = {
      dataType: 'json',
      type: 'GET',
      data: {plugin_name: settings.pluginName},
      cache: false,
      url: "/#{settings.scopedDomainFid}/#{settings.scopedProjectFid}/webconsole/current-context"
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



  @open= (callback) ->
    console.log 'open'
    # Open console container
    @$container.parent().slideDown 'slow', () ->
      WebconsoleContainer.load()
      callback() if callback

  @close= (callback) ->
    console.log 'close'
    @$container.parent().slideUp 'slow', () ->
      console.log('Webconsole closed')
      callback() if callback

  @reload= () ->
    console.log 'reload'
    @load(true)

  @load= (reload=false) ->
    if @loaded && reload==false
      console.log 'alredy loaded'
      return

    # bind this to self
    self = this
    # create loading element
    $loadingHint = $("<div><span class='info-text'>#{@settings.loadingText}</span><span class='spinner'></span></div>")
    # set holder's content to loading
    @$holder.html($loadingHint)

    $loadingHint.append('<span class="status info-text">0%</span>')

    # load token and endpoints
    loadWebconsoleData(@settings).success ( context, textStatus, jqXHR ) ->
      $loadingHint.find('.status').text('20%')

      # load lib
      $.when(
          cachedScript("#{context.webcli_endpoint}/js/hterm.js"),
          cachedScript("#{context.webcli_endpoint}/js/gotty.js"),
          $.Deferred ( deferred ) -> $( deferred.resolve )

      ).done () ->
        $loadingHint.find('.status').text('60%')
        # success
        # load webcli
        $.ajax
          url: "#{context.webcli_endpoint}/auth"
          xhrFields: { withCredentials: true }
          beforeSend: (request) -> request.setRequestHeader('X-Auth-Token', context.token)
          dataType: 'json'
          success: ( data ) ->
            $loadingHint.find('.status').text('80%')
            # success -> add terminal div to container
            self.$holder.append('<div id="terminal"/>')
            # open socket

            openCLIWebsocket data.url, [context.token, context.identity_url], () ->
              if context.help_html
                $helpContainer = addHelpContainer(self.$container, self.settings)
                $helpContainer.html(context.help_html)

              $loadingHint.remove()

            self.loaded = true
          error: (xhr, bleep, error) -> console.log('error: ' + error)
