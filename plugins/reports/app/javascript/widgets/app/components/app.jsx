import NivoBarChart from "./nivoBarChart"
import Details from "./details"
import React, { useState, useEffect } from "react"

const App = ({ cost, fetchCostReport }) => {
  const [clickBarData, setClickBarData] = useState(null)
  const [clickedBar, setClickedBar] = useState("none")
  const [showDetails, setShowDetails] = useState(false)
  const [clickService, setClickService] = useState("all")

  useEffect(() => {
    if (!fetchCostReport) return
    fetchCostReport()
  }, [fetchCostReport])

  useEffect(() => {
    if (!cost?.chartData) return
    // init chart selecting actual month
    if (Object.keys(cost?.chartData)?.length > 0) {
      const { [Object.keys(cost.chartData)[0]]: selectedInitBar } =
        cost.chartData
      setClickBarData(selectedInitBar)
      setShowDetails(true)
      setClickedBar(selectedInitBar?.date)
    }
  }, [cost])

  const onClickBarChart = (data) => {
    if (clickedBar == data.date) {
      setShowDetails(false)
      setClickedBar("none")
    } else {
      setClickBarData(data)
      setShowDetails(true)
      setClickedBar(data.date)
    }
  }

  const onClickLegendRect = (service) => {
    setClickService(service)
  }

  const onCloseDetails = () => {
    setShowDetails(false)
    setClickedBar("none")
    setClickService("all")
  }

  const colors = ["#008fd3", "#be008c", "#fa9100", "#93c939", "#ccc"]
  return (
    <>
      {cost?.error && (
        <>
          <span className="text-danger">{cost?.error?.error}</span>
        </>
      )}

      <NivoBarChart
        cost={cost}
        colors={colors}
        onClick={onClickBarChart}
        clickedBar={clickedBar}
        onClickLegend={onClickLegendRect}
        clickService={clickService}
      />

      <div className="cost-details">
        <Details
          data={clickBarData}
          colors={colors}
          services={cost?.services}
          serviceMap={cost?.serviceMap}
          onClose={onCloseDetails}
          showDetails={showDetails}
          clickService={clickService}
        />
      </div>
    </>
  )
}

export default App
