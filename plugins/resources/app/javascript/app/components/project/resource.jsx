import { OverlayTrigger, Tooltip } from 'react-bootstrap';

import { byUIString, t } from '../../utils';

const ResourceName = ({name, flavorData}) => {
  if (!flavorData.primary || !flavorData.secondary) {
    return <div className='col-md-2'>{name}</div>;
  }

  let tooltip = <Tooltip id={`tooltip-${name}`} className='tooltip-no-break'>{flavorData.secondary}</Tooltip>;
  return (
    <div className='col-md-2'>
      <OverlayTrigger overlay={tooltip} placement='right' delayShow={300} delayHide={150}><span>{name}</span></OverlayTrigger>
      <div><small className='text-muted'>{flavorData.primary}</small></div>
    </div>
  );
};

export default class ProjectResource extends React.Component {
  state = {}

  render() {
    const displayName = t(this.props.resource.name);
    const flavorData = this.props.flavorData[displayName] || {};

    return (
      <div className='row'>
        <ResourceName name={displayName} flavorData={flavorData} />
      </div>
    );
  }
}
