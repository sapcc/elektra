import { t } from '../utils';
import ResourceBar from './resource_bar';
import ResourceName from './resource_name';

export default class UsageOnlyResource extends React.Component {
  render() {
    const { name, usage, unit: unitName } = this.props.resource;
    const { quota, usable_quota: usableQuota } = this.props.parentResource;
    const displayName = t(name);
    const flavorData = this.props.flavorData[displayName] || {};

    return (
      <div className='row usage-only'>
        <ResourceName name={displayName} flavorData={flavorData} small={true} />
        <div className='col-md-5'>
          <ResourceBar
            capacity={quota} fill={usage} unitName={unitName}
            labelIsUsageOnly={true} isDanger={usage > usableQuota} />
        </div>
      </div>
    );
  }
}
