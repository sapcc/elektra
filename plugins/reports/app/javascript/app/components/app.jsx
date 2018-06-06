import BarChart from './barChart'
import { range } from 'd3-array'

class App extends React.Component {

  state = {
    screenWidth: 1000,
    screenHeight: 500,
    hover: "none",
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

  render() {
    return (
      <React.Fragment>
        <BarChart onHoverRect={this.onHoverRect} hoverElement={this.state.hover} data={this.props.cost.data} size={[1170,300]} />
      </React.Fragment>
    )
  }
  }

export default App;
