import AvailabilityZoneCategory from '../../containers/availability_zones/category';

import { byUIString, byNameIn } from '../../utils';

const AvailabilityZoneOverview = ({ isFetching, overview, flavorData }) => {
  if (isFetching) {
    return <p><span className='spinner'/> Loading capacity data...</p>;
  }

  const forwardProps = { flavorData };
  return (
    <React.Fragment>
      <div className='bs-callout bs-callout-info bs-callout-emphasize'>
        This screen shows the available capacity in each availability zone.
        Use this data to choose which availability zone to deploy your application to.
      </div>
      {Object.keys(overview.areas).sort(byUIString).map(area => (
        overview.areas[area].sort(byUIString).map(serviceType => (
          overview.categories[serviceType].sort(byNameIn(serviceType)).map(categoryName => (
            <AvailabilityZoneCategory key={categoryName} categoryName={categoryName} {...forwardProps} />
          ))
        ))
      ))}
    </React.Fragment>
  );
}

export default AvailabilityZoneOverview;
