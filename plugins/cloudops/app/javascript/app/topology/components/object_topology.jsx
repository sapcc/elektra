import React, { Component } from 'react'
import './application.css'
import { scaleLinear } from 'd3-scale'
import { max } from 'd3-array'
import { select } from 'd3-selection'
import { forceSimulation, forceLink, forceCenter, forceManyBody, forceX, forceY } from 'd3-force';
import { timeout } from 'd3-timer'

export default class App extends Component {
  static defaultProps = {
    width: 870,
    height: 600
  };

  componentDidMount() {
    this.d3Graph = d3.select(ReactDOM.findDOMNode(this.refs.graph))

    this.force = d3.layout.force()
      .linkDistance(150)
      .charge(-400)
      .nodes([])
      .links([])
      .size([this.props.width, this.props.height])
      .on('tick', () => {
        // after force calculation starts, call updateGraph
        // which uses d3 to manipulate the attributes,
        // and React doesn't have to go through lifecycle on each tick
        this.d3Graph.call(this.updateGraph);
      });

    this.nodes = this.force.nodes()
    this.links = this.force.links()
    this.props.loadSubtree(this.props.objectId)

    this.force.start()
  }

  shouldComponentUpdate(nextProps) {
    if(!nextProps.topologyObjects) return false;

    let root = this.data(nextProps.topologyObjects)
    root.fixed = true;
    root.x = this.props.width / 2;
    root.y = this.props.height / 2 - 80;

    const nodes = this.flatten(root)
    const links = d3.layout.tree().links(nodes)

    for(let newNode of nodes) {
      let oldNode = this.nodes.findIndex( (i) => i.id == newNode.id)
      if(oldNode<0) this.nodes.push(newNode)
    }

    if(this.links.length==0)
      this.links = links
    else
      for(let newLink of links) {
        let oldLink = this.links.findIndex( (i) => i.source.id == newLink.source.id && i.target.id == newLink.target.id)
        if(oldLink<0 && this.links)
          this.links.push({source: {id: newLink.source.id}, target: {id: newLink.target.id}})
      }
  console.log('this.links',this.links)
    //this.links = links



    var d3Nodes = this.d3Graph.selectAll('.node')
      .data(this.nodes);
    d3Nodes.enter().append('g').call(this.enterNode);
    d3Nodes.exit().remove();
    d3Nodes.call(this.updateNode);

    var d3Links = this.d3Graph.selectAll('.link')
      .data(this.links);
    d3Links.enter().insert('line', '.node').call(this.enterLink);
    d3Links.exit().remove();
    d3Links.call(this.updateLink);

    // we should actually clone the nodes and links
    // since we're not supposed to directly mutate
    // props passed in from parent, and d3's force function
    // mutates the nodes and links array directly
    // we're bypassing that here for sake of brevity in example

    //this.force.nodes(nodes).links(links).start();
    this.force.start()
    return false;
  }

  data = (topologyObjects) => {
    let objects = JSON.parse(JSON.stringify(topologyObjects))
    return objects
  }

  // Returns a list of all nodes under the root.
  flatten = (root) => {
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
    return nodes;
  }

  enterNode = (selection) => {
    selection.classed('node', true);
    selection.call(this.force.drag);
    selection.on('click',this.click)

    selection.append('circle')
      .attr("r", (d) => d.size || 15)
      .style("fill","white")
      .style('stroke', '#000')

    selection.append('text')
      .attr('class','icon')
      .style('font-family', 'FontAwesome')
      .style('font-size', 12)
      .attr("dx", -10).attr("dy",10)
      .text((d) => {
        switch(d.cached_object_type){
          case 'network':
            return  '\uf0c2'
          case 'server':
            return '\uf0a0'
          case 'router':
            return '\uf0e8'
          case 'gateway':
            return  '\uf0ac'
          default:
            return d.cached_object_type
        }
      })

    selection.append('text')
      .attr("x", (d) => (d.size || 5) + 5)
      .attr("dy", ".35em")
      .style('font-size', 12)
      .text((d) => d.name || d.id);
  }

  click = (d) => {
    if (!d.children) {
      this.props.loadSubtree(d.id)
    }
  }

  updateNode = (selection) => {
    selection.attr("transform", (d) => "translate(" + (d.x || 0) + "," + (d.y || 0) + ")");
  }

  enterLink = (selection) => {
    selection.classed('link', true)
      .attr("stroke-width", (d) => d.size || 1.5)
      .style('stroke', '#9ecae1')
  }

  updateLink = (selection) => {
    selection.attr("x1", (d) => d.source.x)
      .attr("y1", (d) => d.source.y)
      .attr("x2", (d) => d.target.x)
      .attr("y2", (d) => d.target.y);
  }

  updateGraph = (selection) => {
    selection.selectAll('.node')
      .call(this.updateNode);
    selection.selectAll('.link')
      .call(this.updateLink);
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
