class Worldmap

  # Ensure Worldmap is available outside of closure
  window.Worldmap ||= Worldmap

  constructor: (container, options={}) ->
    # Map dimensions (in pixels)
    width = 1140
    height = 580

    # Map projection
    projection = d3.geo.miller()
      .scale(174.38214717143913)
      .center([-0.0018057527730042117, 25])
      .translate([width / 2, height / 2]) # translate to center the map in view

    # Generate paths based on projection
    path = d3.geo.path().projection(projection)



    # initialize tooltip
    tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([-10, 0])
      .html((d) ->
        selectedRegionText = if isActiveCity(d) then 'Active Region' else ''
        comingSoonText = if d.available then '' else 'Planned for ' + d.date

        "<strong>Region:</strong> #{d.regionname} <br />" +
        "<span class='d3-tip-info'> #{d.country} </span><br />" +
        "<span class='d3-tip-highlight'> #{selectedRegionText} </span>" +
        "<span class='d3-tip-highlight-secondary'> #{comingSoonText} </span>"
    )

    # special tooltip for active region (will only be displayed on initial page load)
    showActiveTip = (d, i) ->
      if isActiveCity(d)
        thisNode = d3.select(this).node() # current city
        matrix = thisNode.getScreenCTM().translate(thisNode.getAttribute('cx'), thisNode.getAttribute('cy')) # get screen relative coordinates for current city, matrix.e = x-coord, matrix.f = y-coord


        tipContent = "<strong>Region:</strong> #{d.regionname} <br />" +
                     "<span class='d3-tip-info'> #{d.country} </span><br />" +
                     "<span class='d3-tip-highlight'>Active Region</span>"

        div = d3.select('body')
          .append('div')
            .attr('class', 'd3-tip n d3-tip-active')
            .style(position: 'absolute')
            .html(tipContent)
            # compute values for absolute positioning: pageOffset so that positioning adjusts to scrolling if needed, matrix.e is x-coord, matrix.f is y-coord
            .style('left', (d) ->
              tipWidth = @getBoundingClientRect().width
              computedLeft = window.pageXOffset + matrix.e - (tipWidth / 2)
              computedLeft + 'px'
            ).style('top', (d) ->
              tipHeight = @getBoundingClientRect().height
              computedTop = window.pageYOffset + matrix.f - tipHeight - 18
              computedTop + 'px'
            )
      return

    # -------------------------------------------------
    # Event Handlers
    # -------------------------------------------------
    # d.properties contains the attributes (e.g. d.properties.name, d.properties.population)

    clickedCity = (d, i) ->
      if d.available & !isActiveCity(d) # only active and available cities do something on click
        d3.event.stopPropagation() # to prevent clickedWorldMap from triggering
        link = window.location.href.replace(options.current_region, d.regionkey)
        showConfirm 'Do you want to switch to region ' + d.regionname + '?', link
      return


    clickedWorldMap = (d, i) ->
      # hide all tooltips if world map clicked
      d3.selectAll('.d3-tip').style
        opacity: 0
        'pointer-events': 'none'
      return


    mouseoverCity = (d, i) ->
      d3.select(this).attr 'r', 10

      # ensure active region tip is hidden before showing the new tip
      d3.select('.d3-tip-active').style
        opacity: 0
        'pointer-events': 'none'

      tip.show d
      return


    mouseoutCity = (d, i) ->
      d3.select(this).attr 'r', getRadius
      return


    # -------------------------------------------------------------------
    # Helper Functions
    # -------------------------------------------------------------------

    # check if an object is an array. Usage: typeIsArray obj
    typeIsArray = Array.isArray || ( value ) ->
      return {}.toString.call( value ) is '[object Array]'

    # Bootstrap confirm dialog for region switch
    showConfirm = (text, link) ->
      html =  '<div id=\'confirm-region-change\' class=\'modal fade\' style=\'padding-top:15%; overflow-y:visible;\'>' +
                '<div class=\'modal-dialog\'>' +
                  '<div class=\'modal-content\'>' +
                    '<div class=\'modal-header\'>' +
                      '<a class=\'close\' data-dismiss=\'modal\'>×</a>' +
                      '<h4>' + text + '</h4>' +
                    '</div>' +
                    '<div class=\'modal-footer\'>' +
                      '<a data-dismiss=\'modal\' class=\'btn\'>Cancel</a>' +
                      '<button data-dismiss=\'modal\' class=\'btn btn-primary confirm\'>Yes, switch region</button>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>'
      $('#modal-holder').append html
      $('#confirm-region-change').modal 'show'
      $('#confirm-region-change [data-dismiss="modal"].confirm').on 'click', (e) ->
        window.location.assign link
        return
      return

    # Biggest radius for the active city, smaller radius for selectable cities, still smaller radius for future cities
    getRadius = (d, i) ->
      size = if d.available then 7 else 6
      if isActiveCity(d)
        size = size + 1
      size

    isActiveCity = (d, i) ->
      d.regionkey == options.current_region

    # check how far in the future the planned date is
    isComingLater = (d, i) ->
      currentYear = (new Date).getFullYear()
      # if not available and the planned availability year is not the current year return true
      !d.available and (d.date.indexOf(currentYear) < 0)





    # ---------------------------------------------------------------------
    # Render SVG
    # ---------------------------------------------------------------------

    # Create an SVG
    svg = d3.select(container)
      .append('svg')
        .attr('width', width)
        .attr('height', height)
        .on('click', clickedWorldMap)

    # Create tip for cities
    svg.call tip

    # shorthand
    g = svg.append('g')

    # Group for the map features
    features = g.attr('class', 'features')

    # Render Worldmap: Read topodata and convert to paths, add circles for cities
    d3.json '/world_countries.topojson', (error, geodata) ->
      if error
        return console.log(error) # unknown error, check the console

      # Create a path for each map feature in the data
      features.selectAll('path')
        .data(topojson.feature(geodata, geodata.objects.subunits).features)
        .enter()
        .append('path')
        .attr 'd', path

      # Read cities from config file. Render circles for cities
      d3.json options.regions_config, (error, data) ->
        g.selectAll('circle')
          .data(data)
          .enter()
          .append('circle')
          .attr('cx', (d) ->
            projection([d.lon, d.lat])[0])
          .attr('cy', (d) ->
            projection([d.lon, d.lat])[1])
          .attr('r', getRadius)
          .classed(
            'worldmap-city': true
            'active': isActiveCity
            'notavailable': (d) -> !d.available
            'cominglater': isComingLater)
          .each(showActiveTip)
          .on('click', clickedCity)
          .on('mouseover', mouseoverCity)
          .on 'mouseout', mouseoutCity
        return
      return
