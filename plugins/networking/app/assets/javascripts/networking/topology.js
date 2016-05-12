networking.topology = function(container, data) {
  var w = Math.max($(container).innerWidth(), 900),
  h = Math.max($(container).innerHeight(), 500);
    
  console.log("width",w,"height",h);

  var focusNode = null,
    highlightNode = null;

  var minScore = 0;
  var max_score = 1;

  var color = d3.scale.linear()
    .domain([minScore, (minScore + max_score) / 2, max_score])
    .range(["lime", "yellow", "red"]);

  var highlightColor = "blue";

  var size = d3.scale.pow().exponent(1)
    .domain([1, 100])
    .range([8, 24]);

  var force = d3.layout.force()
    .linkDistance(80)
    .charge(-300)
    .size([w, h]);

  var nominalBaseNodeSize = 8;
  var nominalTextSize = 10;
  var maxTextSize = 24;
  var nominalStroke = 1.5;
  var maxStroke = 4.5;
  var maxBaseNodeSize = 36;
  var minZoom = 0.1;
  var maxZoom = 7;
  var svg = d3.select(container).append("svg").attr("width", w).attr("height", h);
  var zoom = d3.behavior.zoom().scaleExtent([minZoom, maxZoom])
  var g = svg.append("g");
  svg.style("cursor", "move");
  
  var nodes = flatten(data),
      links = d3.layout.tree().links(nodes);

  var linkedByIndex = {};
  links.forEach(function(d) {
    linkedByIndex[d.source + "," + d.target] = true;
  });

  function isConnected(a, b) {
    return linkedByIndex[a.index + "," + b.index] || linkedByIndex[b.index + "," + a.index] || a.index == b.index;
  }

  function hasConnections(a) {
    for (var property in linkedByIndex) {
      s = property.split(",");
      if ((s[0] == a.index || s[1] == a.index) && linkedByIndex[property]) return true;
    }
    return false;
  }
  
  function getLook(node){
    switch(node.type){
    case 'router':
      return 'square';
    default: 
      return 'circle';    
    }
  } 
  
  function getSize(node){
    switch(node.type){
    case 'router':
      return 14;
    case 'gateway':
      return 12;  
    case 'network':
      return 10;
    case 'server':
      return 8;    
    default: 
      return 8;    
    }
  }

  force
    .nodes(nodes)
    .links(links)
    .start();

  var link = g.selectAll(".link")
    .data(links)
    .enter().append("line")
    .attr("class", "link")
    .style("stroke-width", nominalStroke);


  var node = g.selectAll(".node")
    .data(nodes)
    .enter().append("g")
    .attr("class", function(d,i){ return "node " + d.type;})
    .call(force.drag)


  var tocolor = "fill";
  var towhite = "stroke";

  
  var circle = node.append("path")
    .attr("d", d3.svg.symbol()
    .size(function(d){ return Math.PI * Math.pow(getSize(d) , 2)})
    .type(getLook))

  var text = g.selectAll(".text")
    .data(nodes)
    .enter().append("text")
    .text(function(node){ return node.name;})
    .attr("class", function(node){return node.type;})
    .attr("dx", function(d) {
      return (getSize(d)+3);
    })

  node.on("mouseover", function(d) {
    setHighlight(d);
  })
  .on("mousedown", function(d) {
    d3.event.stopPropagation();
    focusNode = d;
    setFocus(d)
    if (highlightNode === null) setHighlight(d)
  }).on("mouseout", function(d) {
    exitHighlight();
  });

  d3.select(window).on("mouseup", function() {
    if (focusNode !== null) {
      focusNode = null;
      circle.style("opacity", 1);
      text.style("opacity", 1);
      link.style("opacity", 1);
    }

    if (highlightNode === null) exitHighlight();
  });

  function exitHighlight() {
    highlightNode = null;
    if (focusNode === null) {
      svg.style("cursor", "move");
      text.style("font-weight", "normal");
    }
  }

  function setFocus(d) {
    circle.style("opacity", function(o) {
      return isConnected(d, o) ? 1 : 0.4;
    });

    text.style("opacity", function(o) {
      return isConnected(d, o) ? 1 : 0.4;
    });

    link.style("opacity", function(o) {
      return o.source.index == d.index || o.target.index == d.index ? 1 : 0.4;
    });
  }


  function setHighlight(d) {
    svg.style("cursor", "pointer");
    if (focusNode !== null) d = focusNode;
    highlightNode = d;

    text.style("font-weight", function(o) {
      return isConnected(d, o) ? "bold" : "normal";
    });
  }


  zoom.on("zoom", function() {

    var stroke = nominalStroke;
    if (nominalStroke * zoom.scale() > maxStroke) stroke = maxStroke / zoom.scale();
    link.style("stroke-width", stroke);
    circle.style("stroke-width", stroke);

    var base_radius = nominalBaseNodeSize;
    if (nominalBaseNodeSize * zoom.scale() > maxBaseNodeSize) base_radius = maxBaseNodeSize / zoom.scale();
    
    circle.attr("d", d3.svg.symbol()
      .size(function(d) {
        return Math.PI * Math.pow(getSize(d) * base_radius / nominalBaseNodeSize || base_radius, 2);
      })
      .type(getLook)
    )

    text.attr("dx", function(d) {
      return ( (getSize(d) +3)* base_radius / nominalBaseNodeSize || base_radius);
    });

    var text_size = nominalTextSize;
    if (nominalTextSize * zoom.scale() > maxTextSize) text_size = maxTextSize / zoom.scale();
    text.style("font-size", text_size + "px");

    g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
  });

  svg.call(zoom);

  resize();
  //window.focus();
  d3.select(window).on("resize", resize);

  force.on("tick", function() {

    node.attr("transform", function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });
    text.attr("transform", function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });

    link.attr("x1", function(d) {
      return d.source.x;
    })
      .attr("y1", function(d) {
        return d.source.y;
      })
      .attr("x2", function(d) {
        return d.target.x;
      })
      .attr("y2", function(d) {
        return d.target.y;
      });

    node.attr("cx", function(d) {
      return d.x;
    })
      .attr("cy", function(d) {
        return d.y;
      });
  });

  function resize() {
    var width = Math.max($(container).innerWidth(), 900),
    height = Math.max($(container).innerHeight(), 500);

    svg.attr("width", width).attr("height", height);

    force.size([force.size()[0] + (width - w) / zoom.scale(), force.size()[1] + (height - h) / zoom.scale()]).resume();
    w = width;
    h = height;
  }

  function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }


  function flatten(root) {
    var nodes = [], i = 0;

    function recurse(node) {
      if (node.children) node.children.forEach(recurse);
      if (!node.id) node.id = ++i;
      nodes.push(node);
    }

    recurse(root);
    return nodes;
  }
}
