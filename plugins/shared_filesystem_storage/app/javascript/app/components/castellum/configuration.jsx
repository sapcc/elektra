export default class CastellumConfiguration extends React.Component {
  state = {
  }

  render() {
    return <pre>{JSON.stringify(this.props.resourceConfig, null, 2)}</pre>;
  }
}
