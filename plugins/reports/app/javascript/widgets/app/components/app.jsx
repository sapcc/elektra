import NivoBarChart from "./nivoBarChart"
import Details from "./details"
import React from "react"
class App extends React.Component {
  state = {
    hover: "none",
    clickBarData: null,
    clickedBar: "none",
    filter: "",
    showDetails: false,
    clickService: "all",
  }

  componentDidMount() {
    this.props.fetchCostReport().then(() => {
      // init chart selecting actual month
      if (Object.keys(this.props.cost.chartData).length > 0) {
        var { [Object.keys(this.props.cost.chartData)[0]]: selectedInitBar } =
          this.props.cost.chartData
        this.setState({
          clickBarData: selectedInitBar,
          showDetails: true,
          clickedBar: selectedInitBar.date,
        })
      }
    })
  }

  onHoverRect = (d) => {
    this.setState({ hover: d.data.id })
  }

  onClickBarChart = (data) => {
    if (this.state.clickedBar == data.date) {
      this.setState({ showDetails: false, clickedBar: "none" })
    } else {
      this.setState({
        clickBarData: data,
        showDetails: true,
        clickedBar: data.date,
      })
    }
  }

  onClickLegendRect = (service) => {
    this.setState({ clickService: service })
  }

  onCloseDetails = () => {
    this.setState({
      showDetails: false,
      clickedBar: "none",
      clickService: "all",
    })
  }

  render() {
    const colors = ["#008fd3", "#be008c", "#fa9100", "#93c939", "#ccc"]
    return (
      <React.Fragment>
        {this.props.cost.error && (
          <React.Fragment>
            <span className="text-danger">{this.props.cost.error.error}</span>
          </React.Fragment>
        )}

        <NivoBarChart
          cost={this.props.cost}
          colors={colors}
          onClick={this.onClickBarChart}
          clickedBar={this.state.clickedBar}
          onClickLegend={this.onClickLegendRect}
          clickService={this.state.clickService}
        />

        <div className="cost-details">
          <Details
            data={this.state.clickBarData}
            colors={colors}
            services={this.props.cost.services}
            serviceMap={this.props.cost.serviceMap}
            onClose={this.onCloseDetails}
            showDetails={this.state.showDetails}
            clickService={this.state.clickService}
          />
        </div>
      </React.Fragment>
    )
  }
}

export default App
