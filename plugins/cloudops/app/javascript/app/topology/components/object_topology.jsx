import React, { Component } from 'react'
import './application.css'
import { scaleLinear } from 'd3-scale'
import { max } from 'd3-array'
import { select } from 'd3-selection'
import { forceSimulation, forceLink, forceCenter, forceManyBody, forceX, forceY } from 'd3-force';
import { timeout } from 'd3-timer'


/*
rect {
  fill: none;
  pointer-events: all;
}

.node {
  fill: #000;
}

.cursor {
  fill: none;
  stroke: brown;
  pointer-events: none;
}

.link {
  stroke: #999;
}
*/

const data = (topologyObjects) => {
  let objects = JSON.parse(JSON.stringify(topologyObjects))
  return objects
}

// Returns a list of all nodes under the root.
const flatten = (root) => {
  let nodes = [], i = 0;

  const recurse = (node) => {
    if (node.children) {
      node.size = node.children.reduce((p, v) => p + recurse(v), 0);
    }
    if (!node.id) node.id = ++i;
    nodes.push(node);
    return node.size;
  }

  root.size = recurse(root);
  return nodes.filter((elem, pos, arr) => {
    return arr.indexOf(elem) == pos;
  });
  //
  // return nodes;
}


export default class App extends Component {
  static defaultProps = {
    width: 870,
    height: 600
  };

  tick = () => {
    this.link.attr("x1", (d) => d.source.x)
        .attr("y1", (d) => d.source.y)
        .attr("x2", (d) => d.target.x)
        .attr("y2", (d) => d.target.y)

    this.node.attr("cx", (d) => d.x)
        .attr("cy", (d) => d.y)
  }

  // mousemove = () => {
  //   this.cursor.attr("transform", "translate(" + d3.mouse(this) + ")");
  // }
  //
  // mousedownCanvas = () => {
  //   var point = d3.mouse(this),
  //       node = {x: point[0], y: point[1]},
  //       n = this.nodes.push(node);
  //
  //   // add links to any nearby nodes
  //   this.nodes.forEach(function(target) {
  //     var x = target.x - node.x,
  //         y = target.y - node.y;
  //     if (Math.sqrt(x * x + y * y) < 30) {
  //       this.links.push({source: node, target: target});
  //     }
  //   });
  //
  //   restart();
  // }
  //
  // mousedownNode = (d, i) => {
  //   this.nodes.splice(i, 1);
  //   this.links = this.links.filter(function(l) {
  //     return l.source !== d && l.target !== d;
  //   });
  //   d3.event.stopPropagation();
  //
  //   restart();
  // }

  restart = () => {
    this.node = this.node.data(this.nodes);

    this.node.enter().insert("circle", ".cursor")
        .attr("class", "node")
        .style("fill", "#000")
        .attr("r", 5)
        .on('click', this.click)
        .on('mouseover', d => console.log(d.name, d.cached_object_type))
        // .on("mousedown", this.mousedownNode);

    this.node.exit()
        .remove();

    this.link = this.link.data(this.links);

    this.link.enter().insert("line", ".node")
        .style("stroke", "#999")
        .attr("class", "link");
    this.link.exit().remove();

    this.force.start();
  }

  click = (d) => {
    if (!d.children) {
      this.props.loadSubtree(d.id)
    }
  }

  componentDidMount() {
    this.props.loadSubtree(this.props.objectId)

    let fill = d3.scale.category20();

    this.force = d3.layout.force()
        .size([this.props.width, this.props.height])
        //.nodes([]) // initialize with a single node
        .linkDistance(30)
        .charge(-60)
        .on("tick", this.tick);

    var svg = d3.select(ReactDOM.findDOMNode(this.refs.graph))
        .attr("width", this.props.width)
        .attr("height", this.props.height)
        // .on("mousemove", this.mousemove)
        // .on("mousedown", this.mousedownCanvas);

    svg.append("rect")
        .style("fill", "none")
        .style("pointer-events", "all")
        .attr("width", this.width)
        .attr("height", this.height)


    this.nodes = this.force.nodes()
    this.links = this.force.links()
    this.node = svg.selectAll(".node")
    this.link = svg.selectAll(".link")

    // this.cursor = svg.append("circle")
    //     .attr("r", 30)
    //     .attr("transform", "translate(-100,-100)")
    //     .attr("class", "cursor")


    this.restart();
  }

  shouldComponentUpdate(nextProps) {
    if(!nextProps.topologyObjects) return false
    const root = data(nextProps.topologyObjects)
    const initialNodes = flatten(root)
    const initialLinks = d3.layout.tree().links(initialNodes)

    console.log('initialNodes', initialNodes)
    console.log('initialLinks before', initialLinks)

    // this.nodes.length = 0
    // this.links.length = 0

    for(let n of initialNodes) this.nodes.push(n)
    for(let l of initialLinks) this.links.push(l)


    //
    // if( !root || root.isFetching ) {
    //   this.nodes.length = 0
    //   this.links.length = 0
    // } else {
    //
    //   console.log('-----------------------')
    //   this.links.length = 0
    //
    //
    //
    //   // const newNodes = []
    //   const newLinks = []
    //
    //   const nodesToBeRemoved = []
    //
    //   const loadNodesAndLinks = (node, parentNode) => {
    //
    //     if(node.id) {
    //       console.log('nodeIndex',node.id,this.nodes.findIndex(item => item.id==node.id))
    //       if(this.nodes.findIndex(item => item.id==node.id) < 0) {
    //         this.nodes.push(node)
    //       } else {
    //         // nodesToBeRemoved.push(node)
    //       }
    //       console.log('parentNode',parentNode, 'linkIndex', this.links.findIndex(item => item.source.id==parentNode.id && item.target.id==node.id))
    //       if(parentNode && this.links.findIndex(item => item.source.id==parentNode.id && item.target.id==node.id) < 0) {
    //         console.log('push link', {source: parentNode, target: node })
    //         this.links.push({source: parentNode, target: node })
    //       }
    //
    //       if(node.children) {
    //         for(let sn of node.children) {
    //           loadNodesAndLinks(sn, node)
    //         }
    //       }
    //     }
    //   }
    //
    //   loadNodesAndLinks(root)
    //   console.log('this.nodes', this.nodes)
    //   for(let i of this.links) console.log('source',i.source.id,'target',i.target.id)
    //   console.log('nodesToBeRemoved', nodesToBeRemoved)
    // }

    this.restart()

    // var width = 960,
    //     height = 500;
    //
    // var fill = d3.scale.category20();
    //
    // var force = d3.layout.force()
    //     .size([width, height])
    //     //.nodes(initialNodes) // initialize with a single node
    //     //.links(initialLinks)
    //     .linkDistance(30)
    //     .charge(-60)
    //     .on("tick", tick);
    //
    // var svg = d3.select(ReactDOM.findDOMNode(this.refs.graph))
    //     .attr("width", width)
    //     .attr("height", height)
    //     .on("mousemove", mousemove)
    //     .on("mousedown", mousedownCanvas);
    //
    // svg.append("rect")
    //     .style("fill", "none")
    //     .style("pointer-events", "all")
    //     .attr("width", width)
    //     .attr("height", height);
    //
    // var nodes = force.nodes(),
    //     links = force.links(),
    //     node = svg.selectAll(".node"),
    //     link = svg.selectAll(".link");
    //
    // for(let n of initialNodes) nodes.push(n)
    // for(let l of initialLinks) links.push(l)
    //
    //
    // var cursor = svg.append("circle")
    //     .attr("r", 30)
    //     .attr("transform", "translate(-100,-100)")
    //     .attr("class", "cursor");
    //
    // restart();
    //
    // function mousemove() {
    //   cursor.attr("transform", "translate(" + d3.mouse(this) + ")");
    // }
    //
    // function mousedownCanvas() {
    //   var point = d3.mouse(this),
    //       node = {x: point[0], y: point[1]},
    //       n = nodes.push(node);
    //
    //   // add links to any nearby nodes
    //   nodes.forEach(function(target) {
    //     var x = target.x - node.x,
    //         y = target.y - node.y;
    //     if (Math.sqrt(x * x + y * y) < 30) {
    //       links.push({source: node, target: target});
    //     }
    //   });
    //
    //   restart();
    // }
    //
    // function mousedownNode(d, i) {
    //   nodes.splice(i, 1);
    //   links = links.filter(function(l) {
    //     return l.source !== d && l.target !== d;
    //   });
    //   d3.event.stopPropagation();
    //
    //   restart();
    // }
    //
    // function tick() {
    //   link.attr("x1", function(d) { return d.source.x; })
    //       .attr("y1", function(d) { return d.source.y; })
    //       .attr("x2", function(d) { return d.target.x; })
    //       .attr("y2", function(d) { return d.target.y; });
    //
    //   node.attr("cx", function(d) { return d.x; })
    //       .attr("cy", function(d) { return d.y; });
    // }
    //
    // function restart() {
    //   node = node.data(nodes);
    //
    //   node.enter().insert("circle", ".cursor")
    //       .attr("class", "node")
    //       .style("fill", "#000")
    //       .attr("r", 5)
    //       .on("mousedown", mousedownNode);
    //
    //   node.exit()
    //       .remove();
    //
    //   link = link.data(links);
    //
    //   link.enter().insert("line", ".node")
    //       .style("stroke", "#999")
    //       .attr("class", "link");
    //   link.exit()
    //       .remove();
    //
    //   force.start();
    // }
    return false
  }

  render() {
    console.log('render')
    return (
      <svg width={this.props.width} height={this.props.height}>
        <g ref='graph' />
      </svg>
    )
  }
}
