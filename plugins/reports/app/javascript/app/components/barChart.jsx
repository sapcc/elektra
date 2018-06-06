import { max } from 'd3-array'
import { scaleLinear, scaleBand, scaleOrdinal } from 'd3-scale'
import { select } from 'd3-selection'
import { legendColor } from 'd3-svg-legend'
import { transition } from 'd3-transition'
import { stack } from 'd3-shape'
import { axisBottom, axisLeft } from 'd3-axis'
import {default as UUID} from "node-uuid"

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
    const xMargin = 40
    const yMargin = 25
    const xAxisYpos = this.props.size[1] - yMargin
    const colorScale = this.setColorScale()
    const services = this.getServices()
    const data = this.getData()

    // create legend node
    let legend = legendColor()
      .scale(colorScale)
      .labels(services)

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
    let x = scaleBand()
        .rangeRound([0, chartWidth])
        .paddingInner(0.05)
        .align(0.1)
        .domain(data.map(function(d) { return d.date; }))

    let y = scaleLinear()
        .rangeRound([chartHeight, 0])
        .domain([0, max(data, function(d) { return d.total; })]).nice()

    select(node)
      .selectAll("g.service")
      .data(stack().keys(services)(data))
      .enter().append("g")
        .attr("class", "service")
        .attr("fill", (d,i) => this.setColor(d,i,colorScale))
        .attr("transform", "translate("+xMargin+","+yMargin+")")
      .selectAll("rect")
      .data(function(d) { return d; })
      .enter().append("rect")
        .attr("x", function(d) { return x(d.data.date); })
        .attr("y", function(d) { return y(d[1]); })
        .attr("height", function(d) { return y(d[0]) - y(d[1]); })
        .attr("width", x.bandwidth())
        .attr("class", function(d) { return d.data.month; })
        // .on("mouseover", (d) => this.onHover(d, this))
        .on('mouseover', function(d){
            let selector = "rect."+d.data.month
            select(node)
              .selectAll(selector)
              .style("opacity", 0.5);
        })
        .on("mouseout", function(d) {
          let selector = "rect."+d.data.month
          select(node)
            .selectAll(selector)
            .transition()
            .duration(250)
            .style("opacity", 1);
        });

    // create axis
    let xAxis = axisBottom().scale(x)

    select(node)
      .selectAll("g.xaxis")
      .data([0])
      .enter()
      .append("g")
        .attr("class", "xaxis")
        .attr("transform", "translate("+xMargin+","+xAxisYpos+")")

    select(node)
      .select("g.xaxis")
        .call(xAxis)

    let yAxis = axisLeft().scale(y).ticks(10)

    select(node)
       .selectAll("g.yaxis")
       .data([0])
       .enter()
       .append("g")
         .attr("class", "yaxis")
         .attr("transform", "translate("+xMargin+","+yMargin+")")

     select(node)
      .select("g.yaxis")
        .call(yAxis)

    select(node)
      .select("g.yaxis")
      .selectAll("text.axisName")
        .data([0])
        .enter()
        .append("text")
          .attr("class", "axisName")
          .attr("transform", "rotate(-90)")
          .attr("y", -30)
          .attr("x", -chartHeight/2)
          .attr("fill", "#000")
          .style("text-anchor", "end")
          .text("EUR")
  }

  onHover = (d, _this) => {
    this.props.onHoverRect(d)
  }

  setColor = (d,i,colorScale) => {
    return colorScale(d.key)
  }

  setColorScale = () => {
    return scaleOrdinal()
      .domain(this.getServices())
      .range(["#008fd3", "#be008c", "#fa9100", "#93c939", "#ccc"])
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
      let monthNames = [ "January", "February", "March", "April", "May", "June",
                     "July", "August", "September", "October", "November", "December" ];
      let now = new Date()
      for (let i = 0; i <= 11; i++) {
        let past = new Date(now)
        past.setMonth(now.getMonth() - i)
        let key = past.getFullYear() + '/' + (past.getMonth()+1) // +1 to get the month from 1-12
        resultData[key] = {total: 0, date: key, id: UUID.v4(), month: monthNames[past.getMonth()], year: past.getFullYear()}
        this.getServices().map(i => resultData[key][i] = 0)
      }

      // iterate through data
      this.props.data.map(i => {
        let key = i.year + "/" + i.month
        let service = i.service + "::" + i.measure
        if (resultData[key]) {
          resultData[key][service] = i.price_loc + i.price_sec
          resultData[key]["total"] += i.price_loc + i.price_sec
        } else {
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
