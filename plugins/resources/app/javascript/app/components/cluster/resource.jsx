import { Link } from 'react-router-dom';

import { Unit, valueWithUnit } from '../../unit';
import { t } from '../../utils';
import ResourceBar from '../../components/resource_bar';
import ResourceName from '../../components/resource_name';

export default (props) => {
  const displayName = t(props.resource.name);
  const flavorData = props.flavorData[displayName] || {};

  const { name: resourceName, capacity: reportedCapacity, raw_capacity: reportedRawCapacity, domains_quota: domainsQuota, backend_quota: backendQuota, usage, burst_usage: burstUsage, unit: unitName } = props.resource;
  const capacity = reportedCapacity || 0;
  const rawCapacity = reportedRawCapacity || capacity;

  const unit = new Unit(unitName || "");

  //inside <DetailsModal/>, the resource name is replaced with a caption
  //depending on which fill is shown
  const caption = props.captionOverride
    ? <div className='col-md-2'>{props.captionOverride}</div>
    : <ResourceName name={displayName} flavorData={flavorData} />;
  //inside <DetailsModal/>, the "Resource usage" bar indicates the actual
  //resource usage rather than the quota usage of projects
  const fillProps = { fill: domainsQuota };
  if (props.showUsage) {
    fillProps.fill = usage;
    if (burstUsage > 0) {
      fillProps.labelOverride = (
        <React.Fragment>
          {valueWithUnit(usage - burstUsage, unit)} + {valueWithUnit(burstUsage, unit)} burst
        </React.Fragment>
      );
    }
  }

  let infoMessage = undefined;
  if (rawCapacity != capacity) {
    infoMessage = (
      <span>
        {`${capacity / rawCapacity}x overcommit: Raw capacity = `}
        {valueWithUnit(rawCapacity, unit)}
      </span>
    );
  }

  return (
    <div className='row'>
      {caption}
      <div className={props.wide ? 'col-md-9' : 'col-md-5'}>
        <ResourceBar
          capacity={capacity} {...fillProps} unitName={unitName} overcommitAfter={rawCapacity}
          isDanger={domainsQuota > capacity} scopeData={props.scopeData} />
      </div>
      {!props.wide && (
        <div className='col-md-5'>
          { props.canEdit && <Link to={`/details/${props.categoryName}/${resourceName}`} className='btn btn-primary btn-sm btn-quota-details'>Show domains</Link> }
          {infoMessage}
        </div>
      )}
    </div>
  );
}
