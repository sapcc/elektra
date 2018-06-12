import { scaleOrdinal } from 'd3-scale'
import { legendColor } from 'd3-svg-legend'
import { select } from 'd3-selection'

class Legend extends React.Component {

  componentDidMount() {
    this.createLegend()
  }

  componentDidUpdate() {
    this.createLegend()
  }

  createLegend = () => {
    if (!this.props.cost.data) {
      return
    }

    const node = this.node
    const colorScale = this.setColorScale()
    const services = this.props.services()

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
      .attr("transform", "translate(0," + (this.props.height - (17 * services.length) - 27) + ")")

    select(node)
      .selectAll("g.legend")
      .selectAll("text")
        .style("text-anchor", "start")
        .style("alignment-baseline", "middle")
  }

  setColorScale = () => {
    return scaleOrdinal()
      .domain(this.props.services())
      .range(this.props.colors)
  }

  render() {
    return (
      <React.Fragment>
        {this.props.cost.data &&
          <div className="barChartLegend">
            <svg ref={node => this.node = node} width="100%" height={this.props.height}></svg>
          </div>
        }
      </React.Fragment>
    )
  }
}
export default Legend;
