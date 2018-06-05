import { max } from 'd3-array'
import { scaleLinear, scaleBand, scaleOrdinal } from 'd3-scale'
import { select } from 'd3-selection'
import { legendColor } from 'd3-svg-legend'
import { transition } from 'd3-transition'
import { stack } from 'd3-shape'
import { axisBottom, axisLeft } from 'd3-axis'

class BarChart extends React.Component {

  componentDidMount() {
    this.createBarChart()
  }

  componentDidUpdate() {
    this.createBarChart()
  }

  createBarChart = () => {
    if (!this.props.data) {
      return
    }

    const node = this.node
    const chartWidth = this.props.size[0] - 150
    const chartHeight = this.props.size[1] - 50
    const margin = 25
    const xAxisYpos = this.props.size[1] - margin
    const colorScale = this.setColorScale()
    const services = this.getServices()
    const data = this.getData()
    const legend = legendColor()
      .scale(colorScale)
      .labels(services)

    // create legend node
    select(node)
      .selectAll("g.legend")
      .data([0])
      .enter().append("g")
        .attr("class", "legend")
      .call(legend)

    // Position legend node
    select(node)
      .select("g.legend")
      .attr("transform", "translate(" + (this.props.size[0] - 100) + ", 20)")

    // create chart
    var x = scaleBand()
        .rangeRound([0, chartWidth])
        .paddingInner(0.05)
        .align(0.1)

    var y = scaleLinear()
        .rangeRound([chartHeight, 0])

    x.domain(data.map(function(d) { return d.date; }));
    y.domain([0, max(data, function(d) { return d.total; })]).nice();

    select(node)
      .selectAll("g.service")
      .data(stack().keys(services)(data))
      .enter().append("g")
        .attr("class", "service")
        .attr("fill", (d,i) => this.setColor(d,i,colorScale))
        .attr("transform", "translate("+margin+","+margin+")")
      .selectAll("rect")
      .data(function(d) { return d; })
      .enter().append("rect")
        .attr("x", function(d) { return x(d.data.date); })
        .attr("y", function(d) { return y(d[1]); })
        .attr("height", function(d) { return y(d[0]) - y(d[1]); })
        .attr("width", x.bandwidth())

    // create axis
    const xAxis = axisBottom().scale(x)

    select(node)
       .selectAll("g.xaxis")
       .data([0])
       .enter()
       .append("g")
         .attr("class", "xaxis")
         .attr("transform", "translate("+margin+","+xAxisYpos+")")

    select(node)
      .select("g.xaxis")
        .call(xAxis)

    const yAxis = axisLeft().scale(y).ticks(10)

    select(node)
       .selectAll("g.yaxis")
       .data([0])
       .enter()
       .append("g")
         .attr("class", "yaxis")
         .attr("transform", "translate("+margin+","+margin+")")

     select(node)
      .select("g.yaxis")
        .call(yAxis)
      .append("text")
       .attr("transform", "rotate(-90)")
       .attr("y", 6)
       .attr("dy", ".71em")
       .style("text-anchor", "end")
       .text("Value ($)");
  }

  setColor = (d,i,colorScale) => {
    // if (this.props.hoverElement === d.id) {
    //   return "#FCBC34"
    // } else {
    //   console.log(d.service)
    //   return colorScale(d.service)
    // }
    return colorScale(d.key)
  }

  setColorScale = () => {
    return scaleOrdinal()
      .domain(this.getServices())
      .range(["#008fcc", "#9c277b", "#de8a2e", "#b4ca48", "#ccc", "#f0ab00"])
  }

  getServices = () => {
    if (this.props.data) {
      return [].concat(...this.props.data).map(i => i.service + "::" + i.measure).filter( (item, pos, arr) => arr.indexOf(item)==pos)
    }
  }

  getData = () => {
    if (this.props.data) {
      // init data to have allways 12 months with all services
      let resultData = {}
      let now = new Date()
      for (let i = 0; i <= 11; i++) {
        let past = new Date(now)
        past.setMonth(now.getMonth() - i)
        let key = past.getFullYear() + '/' + past.getMonth()
        resultData[key] = {total: 0, date: key}
        this.getServices().map(i => resultData[key][i] = 0)
      }

      //flate data
      this.props.data.map(i => {
        let key = i.year + "/" + i.month
        let service = i.service + "::" + i.measure
        if (resultData[key]) {
          resultData[key][service] = i.price_loc + i.price_sec
          resultData[key]["total"] += i.price_loc + i.price_sec
        } else {
          console.log("new: " + key)
          resultData[key] = {
            date: i.year + "/" + i.month,
            total: 0
          }
          resultData[key][service] = i.price_loc + i.price_sec
          resultData[key]["total"] += i.price_loc + i.price_sec
        }
      })
      // remove keys to just have array of objects
      let tmp = Object.keys(resultData).map(i => resultData[i])
      return tmp.reverse()
    }
  }

  render() {
    return <svg ref={node => this.node = node} width={this.props.size[0]} height={this.props.size[1]}></svg>
  }
}
export default BarChart;
