import BarChart from './barChart'
import { geoCentroid } from 'd3-geo'
import worlddata from './world'
import { range } from 'd3-array'

const appdata = worlddata.features
  .filter(d => geoCentroid(d)[0] < -20)

appdata
  .forEach((d,i) => {
    const offset = Math.random()
    d.launchday = i
    d.data = range(30).map((p,q) => q < i ? 0 : Math.random() * 2 + offset)
  })

class App extends React.Component {

  state = {
    screenWidth: 1000,
    screenHeight: 500,
    hover: "none",
    brushExtent: [0,40],
    filter: '',
    error: null
  };

  componentDidMount() {
    this.props.fetchCostReport().catch(({errors}) => {
      this.setState({error: errors})
    })
  }

  render() {
    const filteredAppdata = appdata.filter((d,i) => d.launchday >= this.state.brushExtent[0] && d.launchday <= this.state.brushExtent[1])
    return (
      <React.Fragment>
        <h1>Helloo</h1>
        <BarChart data={filteredAppdata} realData={this.props.cost.data} size={[500,500]} />
      </React.Fragment>
    )
  }
  }

export default App;
