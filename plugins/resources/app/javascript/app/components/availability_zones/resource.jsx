import ResourceName from '../resource_name';
import ResourceBar from '../resource_bar';

import { t } from '../../utils';

const renderBar = (resource, serviceType, azName) => {
  const az = resource.per_availability_zone.find(data => data.name == azName) || {};

  //In Manila, we have an overcommit factor for historical reasons. But because
  //of changed usage patterns (more use of autoscaling) shares are fuller than
  //they used to be, and because of disk encryption, deduplication is not as
  //impactful anymore. So we cannot actually promise more than the raw capacity
  //to users. Therefore, for Manila, we show only the raw capacity.
  const capacity = serviceType == 'sharev2' ? az.raw_capacity : az.capacity;

  return <ResourceBar
    capacity={capacity || 0} fill={az.usage || 0} unitName={resource.unit}
    isDanger={false} showsCapacity={true} />;
};

const AvailabilityZoneResource = ({ resource, serviceType, flavorData: allFlavorData, availabilityZones, azColumnWidth }) => {
  const displayName = t(resource.name);
  const flavorData = allFlavorData[displayName] || {};

  return (
    <div className='row'>
      <ResourceName name={displayName} flavorData={flavorData} />
      {availabilityZones.map(azName => (
        <div key={azName} className={`col-md-${azColumnWidth}`}>
          {renderBar(resource, serviceType, azName)}
        </div>
      ))}
    </div>
  );
};

export default AvailabilityZoneResource;
