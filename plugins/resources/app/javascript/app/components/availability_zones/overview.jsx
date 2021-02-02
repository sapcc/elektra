import AvailabilityZoneCategory from '../../containers/availability_zones/category';

import { byUIString, byNameIn } from '../../utils';

const AvailabilityZoneOverview = ({ isFetching, overview, flavorData, scopeData, projectShards, shardingEnabled , projectScope}) => {
  if (isFetching) {
    return <p><span className='spinner'/> Loading capacity data...</p>;
  }

  const forwardProps = { flavorData, scopeData, projectShards, shardingEnabled, projectScope };

  let shardingEnabledMessage = ""
  if (!shardingEnabled && projectScope) {
    shardingEnabledMessage = <div className='bs-callout bs-callout-info bs-callout-emphasize'>
      Why do I see greyed out capacity bars for Cores, Instances and RAM? Because sharding is not enabled for this project. To use all shards and get access to additional resources you need to enable sharding. For more information check the overview site of your project.
    </div>
  }

  return (
    <React.Fragment>
      <div className='bs-callout bs-callout-info bs-callout-emphasize'>
        This screen shows the available capacity (gray bar) and actual current resource usage (blue part) in each availability zone.
        Use this data to choose which availability zone to deploy your application to.
        Please note, it does not account for capacity that has already been assigned but not yet used and therefore may not reflect overall available capacity in the region.
      </div>
      {shardingEnabledMessage}
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
