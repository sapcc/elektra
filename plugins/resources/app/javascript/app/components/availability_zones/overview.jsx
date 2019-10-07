import AvailabilityZoneCategory from '../../containers/availability_zones/category';

export default class AvailabilityZoneOverview extends React.Component {
  render() {
    if (this.props.isFetching) {
      return <p><span className='spinner'/> Loading capacity data...</p>;
    }
    return (
      <pre>{JSON.stringify(this.props.overview, null, 2)}</pre>
    );
  }
}
