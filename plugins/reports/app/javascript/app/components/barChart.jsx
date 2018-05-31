import {max, sum} from 'd3-array'
import {scaleLinear} from 'd3-scale'
import { select } from 'd3-selection'
import { legendColor } from 'd3-svg-legend'
import { transition } from 'd3-transition'
import { scaleThreshold } from 'd3-scale'

class BarChart extends React.Component {

  componentDidMount() {
    this.createBarChart()
  }

  componentDidUpdate() {
    this.createBarChart()
  }

  createBarChart = () => {
    if (!this.props.realData) {
      return
    }
    const node = this.node
    const barWidth = this.props.size[0] / this.getData().length
    const colorScaleOld = scaleThreshold().domain([5,10,20,30]).range(["#75739F", "#5EAFC6", "#41A368", "#93C464"])
    const dataMax = this.getDataMax()
    const yScale = scaleLinear().domain([0, dataMax]).range([0, this.props.size[1]])
    const colorScale = this.setColorScale()
    const services = this.getServices()
    const legend = legendColor()
      .scale(colorScale)
      .labels(services)

    select(node)
      .selectAll("g.legend")
      .data([0])
      .enter()
      .append("g")
      .attr("class", "legend")
      .call(legend)

     select(node)
      .select("g.legend")
      .attr("transform", "translate(" + (this.props.size[0] - 100) + ", 20)")

    select(node)
      .selectAll("rect.bar")
      .data(this.getData())
      .enter()
      .append("rect")
      .attr("class", "bar")
      .on("mouseover", this.props.onHover)

    select(node)
      .selectAll("rect.bar")
      .data(this.getData())
      .exit()
      .remove()

    select(node)
      .selectAll("rect.bar")
      .data(this.getData())
      .attr("x", (d,i) => this.setX(d,i,barWidth))
      .attr("y", (d) => this.setY(d,yScale))
      .attr("height", (d) => this.setHeight(d,yScale))
      .attr("width", barWidth)
      .style("fill",(d,i) =>  this.setColor(d,i,colorScale))
      .style("stroke", "black")
      .style("stroke-opacity", 0.25)
  }

  setX = (d,i,barWidth) => {
    // if (this.props.hoverElement === d.id) {
    //   return "#FCBC34"
    // } else {
    //   return colorScale(d.service)
    // }
    return i * barWidth
  }

  setY = (d, yScale) => {
    return this.props.size[1] - yScale(d.data)
  }

  setHeight = (d, yScale) => {
    return yScale(d.data)
  }

  setColor = (d,i,colorScale) => {
    // if (this.props.hoverElement === d.id) {
    //   return "#FCBC34"
    // } else {
    //   console.log(d.service)
    //   return colorScale(d.service)
    // }
    return colorScale(d.service)
  }

  setColorScale = () => {
    let colorScale = d3.scale.category10()
    if (this.props.realData) {
      colorScale.domain(this.getServices())
    }
    return colorScale
  }

  getServices = () => {
    if (this.props.realData) {
      return [].concat(...this.props.realData).map(i => i.service + "::" + i.measure).filter( (item, pos, arr) => arr.indexOf(item)==pos)
    }
  }

  getData = () => {
    if (this.props.realData) {
      return [].concat(...this.props.realData).map(i => ({data: i.price_loc + i.price_sec, service: i.service + "::" + i.measure}))
    }
  }

  getDataMax = () => {
    if (this.getData()) {
      return max(this.getData().map(i => i.data))
    }
  }

  render() {
    return <svg ref={node => this.node = node} width={500} height={500}></svg>
  }
}
export default BarChart;
