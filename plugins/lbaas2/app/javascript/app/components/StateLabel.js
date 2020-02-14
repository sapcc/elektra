import React from 'react';
import { Label, Tooltip, OverlayTrigger } from 'react-bootstrap';

const StateLabel = ({status}) => {

  const labelParams = (status) => {
    switch (status) {
      case 'ONLINE':
        return {className: "label-success", title: "Entity is operating normally"}
      case 'ACTIVE':
        return {className: "label-success", title: "The entity was provisioned successfully"}
      case 'DELETED':
        return {className: "label-success", title: "The entity has been successfully deleted"}
        
      case 'DRAINING':
        return {className: "label-warning-greyscale", title: "The member is not accepting new connections"}
      case 'DEGRADED':      
        return {className: "label-warning-greyscale", title: "One or more of the entity’s components are in ERROR"}
      case 'OFFLINE':
        return {className: "label-warning-greyscale", title: "Entity is administratively disabled"}
      case 'NO_MONITOR':
        return {className: "label-warning-greyscale", title: "No health monitor is configured for this entity and it’s status is unknown"}
  
      case 'ERROR':
        return {className: "label-danger", title: "Entity is not working/deployed properly"}
  
      case "PENDING_CREATE":
        return {className: 'label-warning', title: "The entity is being created"}
      case "PENDING_UPDATE":
        return {className: 'label-warning', title: "TThe entity is being updated"}
      case "PENDING_DELETE":
        return {className: 'label-warning', title: "The entity is being deleted"}
      default:
        return {className: 'label-info', title: "Unknown state"}
    }
  }

  let params = labelParams(status)

  return ( 
    <React.Fragment>
      <OverlayTrigger placement="top" overlay={<Tooltip id="static-label-tooltip">{params.title}</Tooltip>}>
        <Label className={params.className}>{status}</Label>
      </OverlayTrigger>      
    </React.Fragment>
   );
}
 
export default StateLabel;