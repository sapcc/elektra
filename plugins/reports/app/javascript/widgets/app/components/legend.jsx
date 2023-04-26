import { scaleOrdinal } from "d3-scale"
import { legendColor } from "d3-svg-legend"
import { select } from "d3-selection"
import { decompose } from "d3-decompose"
import jsxToString from "jsx-to-string"
import React, { useCallback, useEffect, useRef } from "react"

const Legend = ({
  clickService,
  height,
  onClickLegend,
  services,
  colors,
  serviceMap,
}) => {
  const node = useRef()

  useEffect(() => {
    if (!node.current) return

    const colorScale = scaleOrdinal().domain(services).range(colors)
    let legend = legendColor().scale(colorScale).labels(services)

    select(node.current)
      .selectAll("g.legend")
      .data([0])
      .enter()
      .append("g")
      .attr("class", "legend")
      .call(legend)

    select(node.current)
      .selectAll("g.legend")
      .selectAll("g.cell")
      .on("click", (d) => {
        if (clickService === d) {
          //active square selected; turn it OFF
          onClickLegend("all")
        } else {
          onClickLegend(d)
        }
      })
      .on("mouseover", (nodeName, index, nodeList) => {
        if (nodeName !== "others") {
          return
        }
        const currentNode = nodeList[index]
        let legend = decompose(
          select("g.legend").attr("transform"),
          false
        ).translate
        let legendEntry = decompose(
          select(currentNode).attr("transform"),
          false
        ).translate
        let top = parseInt(legend[1]) + parseInt(legendEntry[1])
        let left = parseInt(legend[0]) + parseInt(legendEntry[0] + 20)

        select(node.current.parentNode)
          .append("div")
          .attr("class", "customTooltip")
          .style("top", top + "px")
          .style("left", left + "px")
          .style("position", "absolute")
          .style("pointer-events", "none")
          .html(jsxToString(tooltip()))
      })
      .on("mouseout", function () {
        select(node.current.parentNode).select(".customTooltip").remove()
      })

    select(node.current)
      .select("g.legend")
      .attr(
        "transform",
        "translate(3," + (height - 17 * services.length - 27) + ")"
      )
      .selectAll("rect")
      .attr("id", function (d, i) {
        return "id" + d.replace(/\s/g, "")
      })
      .style("stroke-width", 2)
      .style("stroke", (d) => {
        if (clickService === d) {
          return "black"
        } else {
          return "none"
        }
      })
      .style("opacity", (d) => {
        if (clickService === d || clickService === "all") {
          return 1
        } else {
          return 0.5
        }
      })
  }, [clickService, height, onClickLegend, services, colors])

  const tooltip = useCallback(() => {
    return (
      <ul>
        {Object.keys(serviceMap).map((key) => {
          if (serviceMap[key] == "others") {
            return <li key={key}>{key}</li>
          }
        })}
      </ul>
    )
  }, [serviceMap])

  return (
    <>
      <div className="barChartLegend">
        <svg ref={node} width="100%" height={height}></svg>
      </div>
    </>
  )
}

// class Legend extends React.Component {
//   componentDidMount() {
//     this.createLegend()
//   }

//   componentDidUpdate() {
//     this.createLegend()
//   }

//   createLegend = () => {
//     const self = this
//     const node = this.node
//     const services = this.props.services
//     const colorScale = scaleOrdinal().domain(services).range(this.props.colors)

//     let legend = legendColor().scale(colorScale).labels(services)

//     select(node)
//       .selectAll("g.legend")
//       .data([0])
//       .enter()
//       .append("g")
//       .attr("class", "legend")
//       .call(legend)

//     select(node)
//       .selectAll("g.legend")
//       .selectAll("g.cell")
//       .on("click", (d) => {
//         if (this.props.clickService === d) {
//           //active square selected; turn it OFF
//           this.props.onClickLegend("all")
//         } else {
//           this.props.onClickLegend(d)
//         }
//       })
//       .on("mouseover", (nodeName, index, nodeList) => {
//         if (nodeName !== "others") {
//           return
//         }
//         const currentNode = nodeList[index]
//         let legend = decompose(
//           select("g.legend").attr("transform"),
//           false
//         ).translate
//         let legendEntry = decompose(
//           select(currentNode).attr("transform"),
//           false
//         ).translate
//         let top = parseInt(legend[1]) + parseInt(legendEntry[1])
//         let left = parseInt(legend[0]) + parseInt(legendEntry[0] + 20)

//         select(node.parentNode)
//           .append("div")
//           .attr("class", "customTooltip")
//           .style("top", top + "px")
//           .style("left", left + "px")
//           .style("position", "absolute")
//           .style("pointer-events", "none")
//           .html(jsxToString(this.tooltip()))
//       })
//       .on("mouseout", function () {
//         select(node.parentNode).select(".customTooltip").remove()
//       })

//     select(node)
//       .select("g.legend")
//       .attr(
//         "transform",
//         "translate(3," + (this.props.height - 17 * services.length - 27) + ")"
//       )
//       .selectAll("rect")
//       .attr("id", function (d, i) {
//         return "id" + d.replace(/\s/g, "")
//       })
//       .style("stroke-width", 2)
//       .style("stroke", (d) => {
//         if (this.props.clickService === d) {
//           return "black"
//         } else {
//           return "none"
//         }
//       })
//       .style("opacity", (d) => {
//         if (
//           this.props.clickService === d ||
//           this.props.clickService === "all"
//         ) {
//           return 1
//         } else {
//           return 0.5
//         }
//       })
//   }

//   tooltip = () => {
//     return (
//       <ul>
//         {Object.keys(this.props.serviceMap).map((key) => {
//           if (this.props.serviceMap[key] == "others") {
//             return <li key={key}>{key}</li>
//           }
//         })}
//       </ul>
//     )
//   }

//   render() {
//     return (
//       <>
//         <div className="barChartLegend">
//           <svg
//             ref={(node) => (this.node = node)}
//             width="100%"
//             height={this.props.height}
//           ></svg>
//         </div>
//       </>
//     )
//   }
// }
export default Legend
