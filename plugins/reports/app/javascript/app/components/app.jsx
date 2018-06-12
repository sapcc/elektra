import BarChart from './barChart'
import Legend from './legend'
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
    console.log(d)
    this.setState({ hover: d.data.id })
  }

  onClickBarChart = (data) => {
    this.setState({clickData: data})
  }

  getServices = () => {
    return this.props.cost.data.map(i => i.service).filter((item, pos, arr) => arr.indexOf(item)==pos)
  }

  render() {
    const colors = ["#008fd3", "#be008c", "#fa9100", "#93c939", "#ccc"]
    return (
      <React.Fragment>
        <div className="bs-callout bs-callout-info bs-callout-emphasize">
          Cost report for the last 12 months. Click on the columns to show a detailed view for the services.
        </div>
        <div className="row">
          <div className="col-sm-10 col-xs-10">
            <NivoBarChart cost={this.props.cost} colors={colors} services={this.getServices} onClick={this.onClickBarChart}/>
          </div>
          <div className="col-sm-2 col-xs-2">
            <Legend cost={this.props.cost} height="300" colors={colors} services={this.getServices}/>
          </div>
        </div>
        <div className="cost-details">
          <Details data={this.state.clickData} colors={colors} services={this.getServices}/>
        </div>
      </React.Fragment>
    )
  }
}

export default App;
