export default class CastellumFailedOps extends React.Component {
  componentDidMount() {
    this.props.loadOpsOnce(this.props.projectID);
  }

  render() {
    const { errorMessage, isFetching, data } = this.props.operations;
    if (isFetching || data == null) {
      return <p><span className='spinner' /> Loading...</p>;
    }
    if (errorMessage) {
      return <p className='alert alert-danger'>Cannot load operations: {errorMessage}</p>;
    }

    const operations = data.recently_failed_operations || [];
    return <pre>{JSON.stringify(operations, null, 2)}</pre>;
  }
}
