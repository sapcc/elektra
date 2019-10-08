import ResourceName from '../resource_name';

import { t } from '../../utils';

const AvailabilityZoneResource = ({ resource, flavorData: allFlavorData }) => {
  const displayName = t(resource.name);
  const flavorData = allFlavorData[displayName] || {};

  return (
    <div className='row'>
      <ResourceName name={displayName} flavorData={flavorData} />
      <div className='col-md-10'>
        <pre>{JSON.stringify(resource.per_availability_zone, null, 2)}</pre>
      </div>
    </div>
  );
};

export default AvailabilityZoneResource;
