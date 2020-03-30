import React from 'react';
import uniqueId from 'lodash/uniqueId'
import { OverlayTrigger, Popover } from 'react-bootstrap'

const HelpPopover = ({text}) => {

  const popOver =  <Popover id={uniqueId("help-popover-")}>
    {text}
  </Popover>

  return ( 
      <div className="has-feedback-help">
        <OverlayTrigger trigger="click" placement="top" rootClose 
          overlay={popOver}>
          <a className='help-link' href='javascript:void(0)'>
            <i className="fa fa-question-circle"></i>
          </a>
        </OverlayTrigger>
      </div>
   );
}
 
export default HelpPopover;