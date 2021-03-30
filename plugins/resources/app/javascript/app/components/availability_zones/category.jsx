import AvailabilityZoneResource from './resource';

import { Scope } from '../../scope';
import { byUIString, t } from '../../utils';

const AvailabilityZoneCategory = ({ categoryName, category, availabilityZones, flavorData, scopeData, projectShards, shardingEnabled, projectScope }) => {
  const { serviceType, resources } = category;
  const scope = new Scope(scopeData);

  //during buildup, capacity may be displayed in the "unknown" AZ before being
  //assigned to an actual AZ; hide this capacity except for cluster admins
  const visibleAvailabilityZones = scope.isCluster()
    ? availabilityZones
    : availabilityZones.filter(az => az != 'unknown');

  //the resource names use 2 grid columns, so we have 10 grid columns for the
  //AZ bars - choose the column width accordingly
  const azColumnWidth = Math.floor(10 / visibleAvailabilityZones.length);
  const forwardProps = { flavorData, availabilityZones: visibleAvailabilityZones, azColumnWidth, serviceType, projectShards, shardingEnabled, projectScope };

  return (
    <React.Fragment>
      <h3>{t(categoryName)}</h3>
      <div className='row'>
        <div className='col-md-2'>{' '}</div>
        {visibleAvailabilityZones.map(az => (
          <div key={az} className={`col-md-${azColumnWidth}`}><h4>{az}</h4></div>
        ))}
      </div>
      {resources.sort(byUIString).map(res => (
        <AvailabilityZoneResource key={res.name} resource={res} {...forwardProps} />
      ))}
    </React.Fragment>
  );
}

export default AvailabilityZoneCategory;
