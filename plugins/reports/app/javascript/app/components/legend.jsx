import { scaleOrdinal } from 'd3-scale'
import { legendColor } from 'd3-svg-legend'
import { transition } from 'd3-transition'
import { select } from 'd3-selection'
import { decompose } from 'd3-decompose'
import jsxToString from 'jsx-to-string'

class Legend extends React.Component {

  state = {
    activeLink: "0"
  };

  componentDidMount() {
    this.createLegend()
  }

  componentDidUpdate() {
    this.createLegend()
  }

  createLegend = () => {
    const self = this
    const node = this.node
    const services = this.props.services
    const colorScale = scaleOrdinal()
      .domain(services)
      .range(this.props.colors)

    let legend = legendColor()
      .scale(colorScale)
      .labels(services)

    select(node)
      .selectAll("g.legend")
      .data([0])
      .enter().append("g")
        .attr("class", "legend")
      .call(legend)

    select(node)
      .select("g.legend")
      .attr("transform", "translate(3," + (this.props.height - (17 * services.length) - 27) + ")")
      .selectAll("rect")
        .attr("id", function (d, i) {
          return "id" + d.replace(/\s/g, '')
        })
      .on("mouseover", (nodeName,index,nodeList) => {
        if (nodeName !== "others") {
          return
        }

        const currentNode = nodeList[index]
        let legend = decompose(select("g.legend").attr("transform"), false).translate
        let legendEntry = decompose(select(currentNode.parentNode).attr("transform"), false).translate
        let top = parseInt(legend[1]) + parseInt(legendEntry[1])
        let left = parseInt(legend[0]) + parseInt(legendEntry[0] + 20)

        select(node.parentNode)
            .append("div")
            .attr("class", "customTooltip")
            .style("top", top + "px")
            .style("left", left + "px")
            .style("position", "absolute")
            .style("pointer-events", "none")
            .html(jsxToString(this.tooltip()))
      })
      .on("mouseout",function(){
        select(node.parentNode)
          .select(".customTooltip").remove()
       })
      .on('click', (d, e) => {
        if (this.state.activeLink === d) {//active square selected; turn it OFF
          // unborder
          select(node)
            select("#id" + d)
              .style("stroke", "none")

          this.setState({activeLink: "0"})

          //restore remaining boxes to normal opacity
          for (let i = 0; i < services.length; i++) {
            select(node)
              select("#id" + services[i])
                .style("opacity", 1)
          }
          // callback
          this.props.onClickLegend("all")
        } else {
          this.setState({activeLink: d})
          // prittify the selected
          select(node)
            select("#id" + d)
              .style("stroke", "black")
              .style("opacity", 1)
              .style("stroke-width", 2)
          // gray out the others
          for (let i = 0; i < services.length; i++) {
            if (services[i] != this.state.activeLink) {
              select(node)
                select("#id" + services[i])
                  .style("opacity", 0.5)
                  .style("stroke", "none")
            }
          }
          // callback
          this.props.onClickLegend(d)
        }
      })
  }

  tooltip = () => {
    return (<ul>
      {Object.keys(this.props.serviceMap).map( key => {
          if(this.props.serviceMap[key] == "others"){
            return <li key={key}>{key}</li>
          }
        })}
      </ul>)
  }

  render() {
    return (
      <React.Fragment>
        <div className="barChartLegend">
          <svg ref={node => this.node = node} width="100%" height={this.props.height}></svg>
        </div>
      </React.Fragment>
    )
  }
}
export default Legend;
