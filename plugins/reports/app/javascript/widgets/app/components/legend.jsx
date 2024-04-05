import { scaleOrdinal } from "d3-scale"
import { select } from "d3-selection"
import React, { useCallback, useEffect, useRef } from "react"

const Legend = ({ height, onClickLegend, services, colors, serviceMap }) => {
  const node = useRef()
  const tooltip = useRef()

  useEffect(() => {
    if (!node.current) return

    const color = scaleOrdinal().domain(services).range(colors)
    const yPos = (d, i) => 176 + i * 20
    //===================================================
    // select the svg area
    var Svg = select(node.current)

    // because the on click function does not change while the component is rendered
    // we have to manage the clicked service state in memory here
    let currentService
    const legendItems = Svg.selectAll("g.legend")
      .data(services)
      .enter()
      .append("g")
      .attr("class", "legend")
      .on("click", function (d) {
        Svg.selectAll("g.legend").classed("selected", false)
        if (currentService === d) {
          //active square selected; turn it OFF
          onClickLegend("all")
          currentService = "all"
          // remove selected class from the clicked legend item
        } else {
          onClickLegend(d)
          currentService = d
          // add selected class to the clicked legend item
          select(this).classed("selected", true)
        }
      })
      .on("mouseover", function (nodeName, index, nodeList) {
        if (!tooltip.current || nodeName !== "others") return
        tooltip.current.style.display = "block"
        let bbox = tooltip.current.getBoundingClientRect()
        tooltip.current.innerHTML = tooltipContent(nodeName).innerHTML
        let y = yPos(nodeName, index)
        tooltip.current.style.marginLeft = -bbox.width + "px"
        tooltip.current.style.top = y - bbox.height / 2 + "px"
      })
      .on("mouseout", function () {
        if (!tooltip.current) return
        tooltip.current.style.display = "none"
      })

    legendItems
      .append("rect")
      .attr("x", 0)
      .attr("y", yPos)
      .attr("width", 14)
      .attr("height", 14)
      .style("fill", function (d) {
        return color(d)
      })
    legendItems
      .append("text")
      .attr("x", 20)
      .attr("y", (d, i) => yPos(d, i) + 10)
      .text(function (d) {
        return d
      })
  }, [height, onClickLegend, services, colors])

  const tooltipContent = useCallback(
    (showKey) => {
      const ul = document.createElement("ul")
      Object.keys(serviceMap).map((key) => {
        if (!showKey || serviceMap[key] === showKey) {
          const li = document.createElement("li")
          li.textContent = key
          ul.appendChild(li)
        }
      })
      return ul
    },
    [serviceMap]
  )

  return (
    <>
      <div className="barChartLegend">
        <svg ref={node} width="100%" height={height}></svg>
        <div
          ref={tooltip}
          className="customTooltip"
          style={{ display: "none", position: "absolute" }}
        ></div>
      </div>
    </>
  )
}

export default Legend
