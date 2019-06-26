export default class CastellumConfiguration extends React.Component {
  state = {
  }

  render() {
    const { data: config } = this.props.config;
    return <pre>{JSON.stringify(config, null, 2)}</pre>;
  }
}
