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

const renderShard = (resource,azColumnWidth,flavorData,availabilityZones) => {

  let ocFactor = resource.capacity / resource.raw_capacity
  if ('subcapacities' in resource) {
    let subcapacities = resource.subcapacities
    return (
      <div className='row usage-only'>
        <ResourceName name="" flavorData={flavorData} />
        { availabilityZones.map( (azName) => 
            <div key={azName} className={`col-md-${azColumnWidth}`} style={{marginBottom: 5}}>
              { subcapacities.sort(function(a, b) { // https://stackoverflow.com/questions/47998188/how-to-sort-an-object-alphabetically-within-an-array-in-react-js
                  if(a.name.toLowerCase() < b.name.toLowerCase()) return -1;
                  if(a.name.toLowerCase() > b.name.toLowerCase()) return 1;
                  return 0;
                }).map((item) =>
                { 
                  if (item.name.startsWith('vc') ) {
                    if (item.metadata.availability_zone == azName) {
                      let capa = item.capacity
                      if (ocFactor) {
                        capa = item.capacity*ocFactor
                      }
                      return <span>
                          <ResourceBar
                            capacity={capa || 0} fill={item.usage || 0} unitName={resource.unit}
                            isDanger={false} showsCapacity={true}
                            customProgressClass="progress-without-margin" />
                          <span className="text-left shard-name">shard {item.name}</span>
                      </span>
                    }
                  }
                }
              ) }
            </div> 
        ) }
      </div>
    );
  }
}

const AvailabilityZoneResource = ({ resource, serviceType, flavorData: allFlavorData, availabilityZones, azColumnWidth }) => {
  const displayName = t(resource.name);
  const flavorData = allFlavorData[displayName] || {};

  var subcapacitieBars = renderShard(resource, azColumnWidth, flavorData, availabilityZones)


  let resourceBar = (
    <div className='row'>
      <ResourceName name={displayName} flavorData={flavorData} />
      {availabilityZones.map(azName => (
        <div key={azName} className={`col-md-${azColumnWidth}`}>
          {renderBar(resource, serviceType, azName)}
        </div>
      ))}
    </div>
  );


  return [resourceBar,subcapacitieBars]
};

export default AvailabilityZoneResource;
