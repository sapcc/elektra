import { Unit, valueWithUnit } from '../../unit';

export default class DetailsResource extends React.Component {
  //TODO support cluster-level details screen

  //integration points for <DataTable /> parent component
  key() {
    return this.props.metadata.id;
  }

  render() {
    const { name: scopeName, id: scopeID } = this.props.metadata;
    const { quota, usage, burst_usage: burstUsage, unit: unitName } = this.props.resource;

    const unit = new Unit(unitName);

    return (
      <tr>
        <td className='col-md-3'>
          {scopeName}
          <div className='small text-muted'>{scopeID}</div>
        </td>
        <td className='col-md-2'>{valueWithUnit(quota, unit)}</td>
        <td className='col-md-2'>{valueWithUnit(usage, unit)}</td>
        <td className='col-md-2'>{valueWithUnit(burstUsage || 0, unit)}</td>
        <td className='col-md-3'>TODO</td>
      </tr>
    );
  }
}
