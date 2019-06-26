export default class CastellumScrapingErrors extends React.Component {
  componentDidMount() {
    this.props.loadAssetsOnce(this.props.projectID);
  }

  render() {
    const { errorMessage, isFetching, data } = this.props.assets;
    if (isFetching || data == null) {
      return <p><span className='spinner' /> Loading...</p>;
    }
    if (errorMessage) {
      return <p className='alert alert-danger'>Cannot load assets: {errorMessage}</p>;
    }

    //we are only interested in assets with scraping errors
    const assets = (data.assets || []).
      filter(asset => asset.checked && asset.checked.error);

    return <pre>{JSON.stringify(assets, null, 2)}</pre>;
  }
}

