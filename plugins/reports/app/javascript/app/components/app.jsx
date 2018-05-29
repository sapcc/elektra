class App extends React.Component {

  state = {
    filter: '',
    error: null
  };

  componentDidMount() {
    console.log("fetchCostReport")
    console.log(this.props)
    this.props.fetchCostReport().catch(({errors}) => {
      this.setState({error: errors})
    })
  }

  render() {
    return (
      <React.Fragment>
        <h1>Helloo</h1>
      </React.Fragment>
    )
  }
}

export default App;
