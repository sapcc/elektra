import React from 'react';
import uniqueId from 'lodash/uniqueId'
import { OverlayTrigger, Popover } from 'react-bootstrap'

const HelpPopover = ({text}) => {

  const popOver =  <Popover id={uniqueId("help-popover-")}>
    {text}
  </Popover>

  return ( 
      <span className="has-feedback-help">
        <OverlayTrigger trigger="click" placement="top" rootClose 
          overlay={popOver}>
          <a className='help-link' href='#' onClick={e => e.preventDefault()}>
            <i className="fa fa-question-circle"></i>
          </a>
        </OverlayTrigger>
      </span>
   );
}
 
export default HelpPopover;