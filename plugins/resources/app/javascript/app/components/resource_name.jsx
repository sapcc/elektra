import { OverlayTrigger, Tooltip } from 'react-bootstrap';

const ResourceName = ({name, flavorData, small}) => {
  let columnClasses = 'col-md-2 text-right';
  if (small) {
    columnClasses += ' small';
  }

  if (!flavorData.primary || !flavorData.secondary) {
    return <div className={columnClasses}>{name}</div>;
  }

  let tooltip = <Tooltip id={`tooltip-${name}`} className='tooltip-no-break'>{flavorData.secondary}</Tooltip>;
  return (
    <div className={columnClasses}>
      <OverlayTrigger overlay={tooltip} placement='right' delayShow={300} delayHide={150}><span>{name}</span></OverlayTrigger>
      <div className='small text-muted flavor-data'>
        {flavorData.primary.map(text => <span key={text}>{text}</span>)}
      </div>
    </div>
  );
};

export default ResourceName;
