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

  render() {
    return (
      <React.Fragment>
        <BarChart data={this.props.cost.data} size={[700,300]} />
      </React.Fragment>
    )
  }
  }

export default App;
