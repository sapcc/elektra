import React, { Component } from 'react'
import './application.css'
import { scaleLinear } from 'd3-scale'
import { max } from 'd3-array'
import { select } from 'd3-selection'
import { forceSimulation, forceLink, forceCenter, forceManyBody, forceX, forceY } from 'd3-force';
import { timeout } from 'd3-timer'

// import { data1, data2 } from './data'

export default class ObjectTopology extends Component {
   componentDidMount() {
     this.props.loadSubtree(this.props.objectId)
     this.createGraph()
   }

   componentDidUpdate() {
     this.updateGraph()
   }

   data = () => {
     let objects = JSON.parse(JSON.stringify(this.props.topologyObjects))
     return objects
   }

   // Returns a list of all nodes under the root.
   flatten = (root) => {
     var nodes = [], i = 0;

    const recurse = (node) => {
       if (node.children) node.size = node.children.reduce((p, v) => { return p + recurse(v); }, 0);
       if (!node.id) node.id = ++i;
       nodes.push(node);
       return node.size;
     }

     root.size = recurse(root);
     return nodes;
   }

   // Color leaf nodes orange, and packages white or blue.
   color = (d) => {
     return d._children ? "#3182bd" : d.children ? "#c6dbef" : "#fd8d3c";
   }

   // Toggle children on click.
   click = (d) => {
     console.log('d',d)
     // if (d.children) {
     //   d._children = d.children;
     //   d.children = null;
     // } else {
     //   d.children = d._children;
     //   d._children = null;
     // }
     if (!d.children) {
       this.props.loadSubtree(d.id)
     }
     //update();
   }

  createGraph = () => {
    if(!this.props.topologyObjects) return null

    const w = 870
    const h = 600

    //const vis = d3.select(this.node).attr("width", w).attr("height", h);
    //this.graph = vis.append('g')
    this.graph = d3.select(this.node).attr("width", w).attr("height", h);
  }

  // updateGraph = () => {
  //
  //   if(!this.props.topologyObjects) return null
  //
  //   //const svg = this.node
  //   const w = 870
  //   const h = 600
  //
  //   let link
  //   let root
  //   let node
  //
  //   const tick = () => {
  //     link.attr("x1", d => d.source.x)
  //         .attr("y1", d => d.source.y)
  //         .attr("x2", d => d.target.x)
  //         .attr("y2", d => d.target.y)
  //
  //     node.attr("cx", d => d.x)
  //         .attr("cy", d => d.y)
  //         .attr("transform", (d) => "translate(" + d.x + "," + d.y + ")")
  //   }
  //
  //   const force = d3.layout.force()
  //     .on("tick", tick)
  //     .charge(d => d._children ? -d.size / 100 : -30 )
  //     .linkDistance(d => d.target._children ? 80 : 30 )
  //     .size([w, h - 160])
  //
  //   const graph = this.graph
  //
  //   root = this.data()
  //   root.fixed = true;
  //   root.x = w / 2;
  //   root.y = h / 2 - 80;
  //
  //   const nodes = this.flatten(root)
  //   const links = d3.layout.tree().links(nodes)
  //
  //   // Restart the force layout.
  //   force
  //     .linkDistance(80)
  //     .charge(-400)
  //     .nodes(nodes)
  //     .links(links)
  //     .start();
  //
  //   // Update the links…
  //   link = graph.selectAll("line.link")
  //       .data(links, d => d.target.id);
  //
  //   // Enter any new links.
  //   link.enter().insert("svg:line", ".node")
  //       .attr("class", "link")
  //       .style('stroke', '#9ecae1')
  //       .style('stroke-width', '1.5px')
  //       .attr("x1", d => d.source.x)
  //       .attr("y1", d => d.source.y)
  //       .attr("x2", d => d.target.x)
  //       .attr("y2", d => d.target.y);
  //
  //   // Exit any old links.
  //   link.exit().remove();
  //
  //
  //
  //   // Update the nodes…
  //   node = graph.selectAll(".node")
  //       .data(nodes)
  //
  //   let nodeEnter = node.enter().append('g')
  //       .attr('class', 'node')
  //       .style("fill", this.color)
  //       .call(force.drag);
  //
  //   let nodeCircle = nodeEnter.append('circle')
  //     //.attr("r", d => d.children ? 4.5 : Math.sqrt(d.size) / 10);
  //     .attr("r", d => Math.max(15, d.children ? d.children.length : 15))
  //     .style("fill", this.color)
  //     .style('stroke', '#000')
  //     .style('stroke-width', '.5px')
  //     .on("click", this.click)
  //     .call(force.drag);
  //
  //   // Enter any new nodes.
  //   let nodeLabel = nodeEnter.append("text")
  //     .text((d) => d.name || d.id)
  //     .style('font-size', 12)
  //
  //   // Exit any old nodes.
  //   console.log(nodes)
  //   node.exit().remove();
  //
  // }

  updateGraph = () => {
    var svg = this.graph,
        width = +svg.attr("width"),
        height = +svg.attr("height"),
        g = svg.append("g").attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    // var n = 100,
    //     nodes = d3.range(n).map(function(i) { return {index: i}; }),
    //     links = d3.range(n).map(function(i) { return {source: i, target: (i + 3) % n}; });
    let root = this.data()
    root.fixed = true;
    root.x = w / 2;
    root.y = h / 2 - 80;
    const nodes = this.flatten(root)
    const links = d3.layout.tree().links(nodes)

    var simulation = forceSimulation(nodes)
        .force("charge", forceManyBody().strength(-80))
        .force("link", forceLink(links).distance(20).strength(1).iterations(10))
        .force("x", forceX())
        .force("y", forceY())
        //.stop();

    var loading = svg.append("text")
        .attr("dy", "0.35em")
        .attr("text-anchor", "middle")
        .attr("font-family", "sans-serif")
        .attr("font-size", 10)
        .text("Simulating. One moment please…");

    // Use a timeout to allow the rest of the page to load first.
    timeout(function() {
      loading.remove();

      // See https://github.com/d3/d3-force/blob/master/README.md#simulation_tick
      for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
        simulation.tick();
      }

      g.append("g")
          .attr("stroke", "#000")
          .attr("stroke-width", 1.5)
        .selectAll("line")
        .data(links)
        .enter().append("line")
          .attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; });

      g.append("g")
          .attr("stroke", "#fff")
          .attr("stroke-width", 1.5)
        .selectAll("circle")
        .data(nodes)
        .enter().append("circle")
          .attr("cx", function(d) { return d.x; })
          .attr("cy", function(d) { return d.y; })
          .attr("r", 4.5);
    });
  }

  render() {
    if(!this.props.topologyObjects ) return <span className='spinner'></span>
    return (
      <svg ref={node => this.node = node} width={500} height={500}></svg>
    )
   }
}
