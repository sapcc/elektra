import React from 'react';
import { useMemo } from 'react'
import { Label, Tooltip, OverlayTrigger } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'

const StateLabel = ({label}) => {
  const {labelStateAttributes} = useCommons()

  let params = labelStateAttributes(label)
  return useMemo(() => {
    return ( 
      <React.Fragment>
        <OverlayTrigger placement="top" overlay={<Tooltip bsClass="lbaas2 tooltip"id="static-label-tooltip"><b>Operating Status</b><br/>{params.title}</Tooltip>}>
          <Label className={params.labelClassName}>{label}</Label>
        </OverlayTrigger>      
      </React.Fragment>
    );
  }, [label])
}
 
export default StateLabel;