import AvailabilityZoneResource from './resource';

import { t } from '../../utils';

const AvailabilityZoneCategory = ({ categoryName, category, flavorData }) => {
  const { serviceType, resources } = category;
  return (
    <React.Fragment>
      <h3>{t(categoryName)}</h3>
      {resources.map(res => (
        <AvailabilityZoneResource key={res.name} resource={res} flavorData={flavorData} />
      ))}
    </React.Fragment>
  );
}

export default AvailabilityZoneCategory;
