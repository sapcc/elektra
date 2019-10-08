import AvailabilityZoneResource from './resource';

import { t } from '../../utils';

const AvailabilityZoneCategory = ({ categoryName, category, availabilityZones, flavorData }) => {
  const { serviceType, resources } = category;

  //the resource names use 2 grid columns, so we have 10 grid columns for the
  //AZ bars - choose the column width accordingly
  const azColumnWidth = Math.floor(10 / availabilityZones.length);
  const forwardProps = { flavorData, availabilityZones, azColumnWidth };

  return (
    <React.Fragment>
      <h3>{t(categoryName)}</h3>
      <div className='row'>
        <div className='col-md-2'>{' '}</div>
        {availabilityZones.map(az => (
          <div key={az} className={`col-md-${azColumnWidth}`}><h4>{az}</h4></div>
        ))}
      </div>
      {resources.map(res => (
        <AvailabilityZoneResource key={res.name} resource={res} {...forwardProps} />
      ))}
    </React.Fragment>
  );
}

export default AvailabilityZoneCategory;
