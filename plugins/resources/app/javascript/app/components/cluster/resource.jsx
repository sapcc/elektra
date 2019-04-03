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
  const barProps = { fill: domainsQuota };
  if (props.showUsage) {
    barProps.fill = usage;
    if (burstUsage > 0) {
      barProps.labelOverride = (
        <React.Fragment>
          {valueWithUnit(usage - burstUsage, unit)} + {valueWithUnit(burstUsage, unit)} burst
        </React.Fragment>
      );
    }
  }

  let infoMessage = undefined;
  if (rawCapacity > 0 && rawCapacity < capacity) {
    barProps.overcommitAfter = rawCapacity;
    barProps.beforeOvercommitTooltip = `Raw capacity = ${unit.format(rawCapacity)}`;
    barProps.afterOvercommitTooltip = `${capacity / rawCapacity}x overcommit`;
    infoMessage = `${capacity / rawCapacity}x overcommit`;
  }

  if (domainsQuota > capacity) {
    infoMessage = (
      <span className='resource-error text-danger'>
        <i className='fa fa-lg fa-warning' />{' '}
        Quota assignments exceed measured capacity
      </span>
    );
  }

  return (
    <div className='row'>
      {caption}
      <div className={props.wide ? 'col-md-9' : 'col-md-5'}>
        <ResourceBar
          capacity={capacity} {...barProps} unitName={unitName}
          isDanger={barProps.fill > capacity} scopeData={props.scopeData} />
      </div>
      {!props.wide && (
        <div className='col-md-5'>
          <Link to={`/details/${props.categoryName}/${resourceName}`} className='btn btn-primary btn-sm btn-quota-details'>Show domains</Link>
          {infoMessage}
        </div>
      )}
    </div>
  );
}
