import React from 'react';
import { useMemo } from 'react'
import { Label, Tooltip, OverlayTrigger } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'

const StatusLabel = ({label}) => {
  const {labelStatusAttributes} = useCommons()

  let params = labelStatusAttributes(label)
  return useMemo(() => {
    return ( 
      <React.Fragment>
        <OverlayTrigger placement="top" overlay={<Tooltip id="static-label-tooltip"><b>Provisioning Status</b><br/>{params.title}</Tooltip>}>
          <b className={`small ${params.textClassName}`}>{label}</b>
        </OverlayTrigger>      
      </React.Fragment>
    );
  }, [label])
}
 
export default StatusLabel;