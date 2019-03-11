import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const ResourceName = ({name, flavorData}) => {
  if (!flavorData.primary || !flavorData.secondary) {
    return <div className='col-md-2 text-right'>{name}</div>;
  }

  let tooltip = <Tooltip id={`tooltip-${name}`} className='tooltip-no-break'>{flavorData.secondary}</Tooltip>;
  // TODO: line breaks make the .small.text-muted.flavor-data look ugly -- maybe place below bar like we had for .resource-error?
  return (
    <div className='col-md-2 text-right'>
      <OverlayTrigger overlay={tooltip} placement='right' delayShow={300} delayHide={150}><span>{name}</span></OverlayTrigger>
      <div className='small text-muted flavor-data'>
        {flavorData.primary.map(text => <span key={text}>{text}</span>)}
      </div>
    </div>
  );
};

export default ResourceName;
