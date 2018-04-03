import { formatModificationTime } from 'lib/tools/date_formatter';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

export const PrettyDate = ({date}) => {
  let tooltip = <Tooltip id='dateTooltip'>{new Date(date).toLocaleDateString()}</Tooltip>;

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}>
      <span>{formatModificationTime(date)}</span>
    </OverlayTrigger>
  )
}
