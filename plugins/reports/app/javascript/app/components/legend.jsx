import { scaleOrdinal } from 'd3-scale'
import { legendColor } from 'd3-svg-legend'
import { transition } from 'd3-transition'
import { select } from 'd3-selection'

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
        return "id" + d.replace(/\s/g, '');
      })
      .on('click', (d, e) => {
        if (this.state.activeLink === "0") { //nothing selected, turn on this selection
          this.setState({activeLink: d})
          // border the selected
          select(node)
            select("#id" + d)
              .style("stroke", "black")
              .style("stroke-width", 2);
          // gray out the others
          for (let i = 0; i < services.length; i++) {
            if (services[i] != this.state.activeLink) {
              select(node)
                select("#id" + services[i])
                  .style("opacity", 0.5);
            }
          }
          // callback
          this.props.onClickLegend(d)
        } else { //deactivate
          if (this.state.activeLink === d) {//active square selected; turn it OFF
            // unborder
            select(node)
              select("#id" + d)
                .style("stroke", "none");

            this.setState({activeLink: "0"})

            //restore remaining boxes to normal opacity
            for (let i = 0; i < services.length; i++) {
              select(node)
                select("#id" + services[i])
                  .style("opacity", 1);
            }
            // callback
            this.props.onClickLegend("all")
          }
        }

      })

    select(node)
      .select("g.legend")


    select(node)
      .selectAll("g.legend")
      .selectAll("text")
        .style("text-anchor", "start")
        .style("alignment-baseline", "middle")
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
