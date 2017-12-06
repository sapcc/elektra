class Topology
  defaults =
    nominalBaseNodeSize: 18
    nominalTextSize: 12
    maxTextSize: 24
    nominalStroke: 1.5
    maxStroke: 4.5
    maxBaseNodeSize: 36
    minZoom: 0.1
    maxZoom: 7

  # container is a DOM element, data is a json
  constructor: (container, data, options={}) ->
    console.log(options)
    @containerSelector = container
    @options = $.extend defaults, options
    # create popover template with left arrow and add it to container
    popoverHolder = $('<div class="networking"></div>').appendTo('body')
    $popover = $('<div class="topology popover fade right in" role="tooltip">
      <div class="arrow" style="top: 20px"></div>
      <h3 class="popover-title">Details</h3>
      <div class="popover-content"></div></div>'
    ).appendTo(popoverHolder)

    @width = Math.max($(container).innerWidth(), 900)
    @height = Math.max($(container).innerHeight(), 500)

    @focusNode = null
    @heightighlightNode = null

    # create svg element
    @canvas = d3.select(container).append("svg").attr("width", @width).attr("height", @height).style("cursor", "move")
    # zoom feature
    zoom = d3.behavior.zoom().scaleExtent([@options.minZoom, @options.maxZoom])
    # create graph container
    @graph = @canvas.append("g").attr("class", "topology")

    # convert data to nodes and links
    nodes = flatten(data)
    links = d3.layout.tree().links(nodes)

    @linksedByIndex = {}
    links.forEach (d) => @linksedByIndex[d.source + "," + d.target] = true

    # create force layout
    @layout = d3.layout.force()
      .linkDistance(80)
      .charge(-400)
      .size([@width, @height])
      .nodes(nodes)
      .links(links)
      .start()

    # add links to graph
    @links = @graph.selectAll(".link")
      .data(links)
      .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", @options.nominalStroke)

    # add nodes to graph
    @nodes = @graph.selectAll(".node")
      .data(nodes)
      .enter().append("g")
      .attr("class", (d,i) -> return "node " + d.type )
      .call(@layout.drag)

    # add circles to nodes
    @circle = @nodes.append("circle")
      .attr("r",@options.nominalBaseNodeSize)
      .style("fill","white")

    # add icons to nodes
    @icons = @nodes.append('text')
      .attr('class','icon')
      .style('font-family', 'FontAwesome')
      .style('font-size', @options.nominalBaseNodeSize)
      .attr("dx", -@options.nominalBaseNodeSize / 2+1).attr("dy",@options.nominalBaseNodeSize / 2 -2)
      .text (d) ->
        switch d.type
          when 'network' then '\uf0c2'
          when 'server' then '\uf0a0'
          when 'router' then '\uf0e8'
          when 'gateway' then '\uf0ac'

    # add labels to nodes
    @labels = @nodes.append("text")
      .attr("class","label")
      .text( (node) -> return node.name )
      .style("font-size",@options.nominalTextSize)
      .style("font-weight","normal")
      .attr("dx", @options.nominalBaseNodeSize+2)


    @dragFlag = false
    # define callbacks for mouse events
    @nodes
      .on "mousemove", (d) => @dragFlag = true
      .on "mouseover", (d) => @setHighlight(d)
      .on "mousedown", (d) =>
        @dragFlag = false
        d3.event.stopPropagation()
        @focusNode = d
        @setFocus(d)
        @setHighlight(d) if @heightighlightNode is null
      .on "mouseout", (d) => @exitHighlight()
      .on "mouseup", (d,i) =>
        if (!@dragFlag)
          # show popover
          if $popover.is(':visible') and $popover.data("currentNode")==d.id
            $popover.hide()
            return false

          $graph = $($(container+' g.topology')[0])
          $element = $($(container+' g.node')[i])

          scale = 1
          scale = parseFloat($graph.attr("scale")) if $graph.length>0 && $graph.attr("scale")

          $popover.css({
            top: $element.offset().top-@options.nominalBaseNodeSize+(@options.nominalBaseNodeSize*scale),
            left: $element.offset().left+(@options.nominalBaseNodeSize*2*scale)
          })

          title = d.type+ if d.name then " ("+d.name+")" else ''
          title = title[0].toUpperCase() + title.slice(1)

          $popover.find('.popover-title').text(title)
          $popover.find('.popover-content').html('<span class="spinner"></span>')
          $popover.show('fast')
          @getNodeDetails d.type,d.id, (html,status) ->
            if status==404
              $element.attr('class',$element.attr('class')+' not-found')
              html = "This #{d.type} does not exist anymore or you don't have permissions to access it."  

            $popover.find('.popover-content').html(html)
            $popover.data("currentNode",d.id)


    d3.select(window).on "mouseup", () =>
      unless @focusNode is null
        @focusNode = null
        @graph.selectAll(".node text").style("opacity",1)

        @circle.style("opacity", 1)
        @labels.style("opacity", 1)
        @links.style("opacity", 1)

      if @heightighlightNode is null
        @exitHighlight()
        $popover.hide()

    # define zoom behavior
    zoom.on "zoom", () =>
      stroke = @options.nominalStroke
      stroke = @options.maxStroke / zoom.scale() if (@options.nominalStroke * zoom.scale() > @options.maxStroke)
      @links.style("stroke-width", stroke)
      @circle.style("stroke-width", stroke)

      baseRadius = @options.nominalBaseNodeSize
      baseRadius = @options.maxBaseNodeSize / zoom.scale() if (@options.nominalBaseNodeSize * zoom.scale() > @options.maxBaseNodeSize)

      textSize = @options.nominalTextSize
      textSize = @options.maxTextSize / zoom.scale() if (@options.nominalTextSize * zoom.scale() > @options.maxTextSize)
      @labels.style("font-size", textSize + "px")

      @graph.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
       .attr("dx",d3.event.translate[0])
       .attr("dy",d3.event.translate[1])
      .attr("scale", zoom.scale())

    @canvas.call(zoom)

    d3.select(window).on "resize", @resize

    @layout.on "tick", () =>
      @nodes.attr "transform", (d) -> "translate(" + d.x + "," + d.y + ")"
      @links.attr "x1", (d) -> d.source.x
        .attr "y1", (d) -> d.source.y
        .attr "x2", (d) -> d.target.x
        .attr "y2", (d) -> d.target.y

      @nodes.attr "cx", (d) -> d.x
        .attr "cy", (d) -> d.y

  getNodeDetails: (type,id,callback) ->
    @nodeDetails ||= {}
    key = "#{type}_#{id}"
    return callback(@nodeDetails[key].content,@nodeDetails[key].status) if @nodeDetails[key]

    $.get("#{@options.details_url}", {type: "#{type}", id: "#{id}"})
      .error ( jqXHR, textStatus, errorThrown) =>
        @nodeDetails[key] = {status: jqXHR.status, content: ''}
        callback("Loading error.",jqXHR.status)
      .done (data, status, xhr) =>
        url = xhr.getResponseHeader('Location')
        # got a redirect response
        if url
          # close modal window
          $('#modal-holder').find('.modal').modal('hide')
          window.location = url
        else
          @nodeDetails[key] = {status: 200, content: data}
          callback(data,200)

  isConnected: (a, b) ->
    @linksedByIndex[a.index + "," + b.index] || @linksedByIndex[b.index + "," + a.index] || a.index == b.index


  hasConnections: (a) ->
    for property, index of @linksedByIndex
      s = property.split(",")
      if (s[0] == a.index || s[1] == a.index) && @linksedByIndex[property] then return true

    return false

  exitHighlight: () ->
    @heightighlightNode = null
    if @focusNode is null
      @canvas.style("cursor", "move")
      @labels.style("font-weight", "normal")


  setFocus: (d) ->
    @graph.selectAll('.node .icon').style("opacity", (o) => if @isConnected(d, o) then 1 else 0.4)
    @labels.style("opacity", (o) => if @isConnected(d, o) then 1 else 0.4)
    @links.style("opacity", (o) -> o.source.index == d.index || o.target.index == if d.index then 1 else 0.4)
    @icons.style("opacity", (o) => if @isConnected(d, o) then 1 else 0.4)

  setHighlight: (d) ->
    @canvas.style("cursor", "pointer")
    d = @focusNode unless @focusNode is null
    @heightighlightNode = d

    @labels.style("font-weight", (o) => if @isConnected(d, o) then "bold" else "normal")

  resize: () ->
    newWidth = Math.max($(@containerSelector).innerWidth(), 900)
    newHeight = Math.max($(@containerSelector).innerHeight(), 500)

    @canvas.attr("width", newWidth).attr("height", newHeight)

    @layout.size([force.size()[0] + (newWidth - @width) / zoom.scale(), force.size()[1] + (newHeight - @height) / zoom.scale()]).resume()
    @width = newWidth
    @height = newHeight

  flatten= (root) ->
    nodes = []
    i = 0

    recurse= (node) ->
      if node.children then node.children.forEach(recurse)
      unless node.id then node.id = ++i
      nodes.push(node)

    recurse(root)
    return nodes


networking.Topology ||= Topology
