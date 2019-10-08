import AvailabilityZoneCategory from '../../containers/availability_zones/category';

const AvailabilityZoneOverview = ({ isFetching, overview, flavorData }) => {
  if (isFetching) {
    return <p><span className='spinner'/> Loading capacity data...</p>;
  }

  return (
    <React.Fragment>
      {Object.keys(overview.areas).map(area => (
        overview.areas[area].map(serviceType => (
          overview.categories[serviceType].map(categoryName => (
            <AvailabilityZoneCategory key={categoryName} categoryName={categoryName} flavorData={flavorData} />
          ))
        ))
      ))}
    </React.Fragment>
  );
}

export default AvailabilityZoneOverview;
