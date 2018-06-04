import { max, sum } from 'd3-array'
import { scaleLinear, scaleThreshold, scaleBand } from 'd3-scale'
import { select } from 'd3-selection'
import { legendColor } from 'd3-svg-legend'
import { transition } from 'd3-transition'
import { stack } from 'd3-shape'

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
    const width = this.props.size[0]
    const height = this.props.size[1]
    const colorScaleOld = scaleThreshold().domain([5,10,20,30]).range(["#75739F", "#5EAFC6", "#41A368", "#93C464"])
    const dataMax = this.getDataMax()
    const yScale = scaleLinear().domain([0, dataMax]).range([0, this.props.size[1]])
    const colorScale = this.setColorScale()
    const services = this.getServices()
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
    //  select(node)
    //   .select("g.legend")
    //   .attr("transform", "translate(" + (this.props.size[0] - 100) + ", 20)")

    // select(node)
    //   .selectAll("rect.bar")
    //   .data(this.getData())
    //   .enter()
    //   .append("rect")
    //   .attr("class", "bar")
    //   .on("mouseover", this.props.onHover)

    // select(node)
    //   .selectAll("rect.bar")
    //   .data(this.getData())
    //   .exit()
    //   .remove()

    console.log(stack().keys(this.getServices())(this.getTestData()))
    console.log(this.getDates())
    console.log(this.getServices())
    console.log(this.getTestData())

    var x = scaleBand()
        .rangeRound([0, width])
        .paddingInner(0.05)
        .align(0.1);

    var y = scaleLinear()
        .rangeRound([height, 0]);

    x.domain(this.getTestData().map(function(d) { return d.date; }));
    y.domain([0, d3.max(this.getTestData(), function(d) { return d.total; })]).nice();

    select(node)
      .selectAll("g.service")
      .data(stack().keys(this.getServices())(this.getTestData()))
      .enter().append("g")
        .attr("class", "service")
        .attr("fill", (d,i) => this.setColorV2(d,i,colorScale))
      .selectAll("rect")
      .data(function(d) { return d; })
      .enter().append("rect")
        .attr("x", function(d) { console.log(d.data.date);console.log(x(d.data.date)); return x(d.data.date); })
        .attr("y", function(d) { return y(d[1]); })
        .attr("height", function(d) { return y(d[0]) - y(d[1]); })
        .attr("width", x.bandwidth());

    // select(node)
    //   .selectAll("g")
    //   .data(stack().keys(this.getServices())(this.getTestData()))
    //   .enter().append("g")
    //     .attr("fill", (d,i) => this.setColorV2(d,i,colorScale))
    //   .selectAll("rect")
    //   .data(function(d) { console.log(d); return d; })
    //   .enter().append("rect")
    //     .attr("x", function(d) { console.log(x(d.data.Date)); return x(d.data.Date); })
    //     .attr("y", function(d) { return y(d[1]); })
    //     .attr("height", function(d) { return y(d[0]) - y(d[1]); })
    //     .attr("width", x.bandwidth());

    // select(node)
    //   .selectAll("rect.bar")
    //   .data(this.getData())
    //   .attr("x", (d,i) => this.setX(d,i,barWidth))
    //   .attr("y", (d) => this.setY(d,yScale))
    //   .attr("height", (d) => this.setHeight(d,yScale))
    //   .attr("width", barWidth)
    //   .style("fill",(d,i) =>  this.setColor(d,i,colorScale))
    //   .style("stroke", "black")
    //   .style("stroke-opacity", 0.25)
  }

  setX = (d,i,barWidth) => {
    return i * barWidth
  }

  setY = (d, yScale) => {
    return this.props.size[1] - yScale(d.data)
  }

  setHeight = (d, yScale) => {
    return yScale(d.data)
  }

  setColorV2 = (d,i,colorScale) => {
    console.log(d)
    return colorScale(d.key)
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

  getDates = () => {
    if (this.props.realData) {
      return [].concat(...this.props.realData).map(i => i.year + "/" + i.month).filter( (item, pos, arr) => arr.indexOf(item)==pos)
    }
  }

  getData = () => {
    if (this.props.realData) {
      return [].concat(...this.props.realData)
                .map(i => {
                  let key = i.year + "/" + i.month
                  let data = {data: i.price_loc + i.price_sec, service: i.service + "::" + i.measure, date: i.year + "/" + i.month}
                  data[key] = i.year + "/" + i.month
                  return data
                })
    }
  }

getTestData = () => {
  if (this.props.realData) {
    let resultData = {}
    let temp = [].concat(...this.props.realData) //flate data
    temp.map(i => {
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
    return Object.keys(resultData).map(i => resultData[i]) // remove keys to just have array of objects
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
