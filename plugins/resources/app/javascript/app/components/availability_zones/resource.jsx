import ResourceName from '../resource_name';
import ResourceBar from '../resource_bar';

import { t } from '../../utils';

const renderBar = (resource, azName) => {
  const az = resource.per_availability_zone.find(data => data.name == azName) || {};
  return <ResourceBar
    capacity={az.capacity || 0} fill={az.usage || 0} unitName={resource.unit}
    isDanger={false} showsCapacity={true} />;
};

const AvailabilityZoneResource = ({ resource, flavorData: allFlavorData, availabilityZones, azColumnWidth }) => {
  const displayName = t(resource.name);
  const flavorData = allFlavorData[displayName] || {};

  return (
    <div className='row'>
      <ResourceName name={displayName} flavorData={flavorData} />
      {availabilityZones.map(azName => (
        <div key={azName} className={`col-md-${azColumnWidth}`}>
          {renderBar(resource, azName)}
        </div>
      ))}
    </div>
  );
};

export default AvailabilityZoneResource;
