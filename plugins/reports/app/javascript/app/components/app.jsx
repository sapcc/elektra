import NivoBarChart from './nivoBarChart'
import Details from './details'

class App extends React.Component {

  state = {
    hover: "none",
    clickData: null,
    filter: '',
    error: null
  };

  componentDidMount() {
    this.props.fetchCostReport().catch(({errors}) => {
      this.setState({error: errors})
    })
  }

  onHoverRect = (d) => {
    this.setState({ hover: d.data.id })
  }

  onClickBarChart = (data) => {
    this.setState({clickData: data})
  }

  onCloseDetails = () => {
    this.setState({clickData: null})
  }

  render() {
    const colors = ["#008fd3", "#be008c", "#fa9100", "#93c939", "#ccc"]
    return (
      <React.Fragment>
        <div className="bs-callout bs-callout-info bs-callout-emphasize">
          Cost report for the last 12 months. Click on the columns to show a detailed view for the services.
        </div>

        <NivoBarChart cost={this.props.cost} colors={colors} onClick={this.onClickBarChart}/>

        <div className="cost-details">
          <Details data={this.state.clickData} colors={colors} services={this.props.cost.services} serviceMap={this.props.cost.serviceMap} onClose={this.onCloseDetails}/>
        </div>
      </React.Fragment>
    )
  }
}

export default App;
