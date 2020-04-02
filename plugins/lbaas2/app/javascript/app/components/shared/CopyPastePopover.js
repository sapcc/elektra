import React, { useState, useEffect } from 'react';
import uniqueId from 'lodash/uniqueId'
import { OverlayTrigger, Overlay, Popover, Tooltip } from 'react-bootstrap'
import Clipboard from 'react-clipboard.js';

const CopyPastePopover = ({text, size, autoClose}) => {
  const [showTooltip, setShowTooltip] = useState(false)
  const [target, setTarget] = useState(null)
  const [showIcon, setShowIcon] = useState(false)
  
  const [showPopover, setShowPopover] = useState(false)
  const [popoverTarget, setPopoverTarget] = useState(null)


  useEffect(() => {
    if (autoClose && showPopover) setShowPopover(false)
  },[autoClose])

  const onCopySuccess = () => {
    setShowTooltip(true)
    setTimeout(() => setShowTooltip(false),500)
  }

  const tooltip = <Overlay
      show={showTooltip}
      placement="top"
      container={this}
      target={target}>
      <Tooltip id={uniqueId("copy-paste-tooltip-")}>Copied!</Tooltip>
    </Overlay>

  const popOver =  <Popover id={uniqueId("copy-paste-popover-")}>
    <div className="lbaas2">
        <span>{text}</span>
        <div className="text-right">
          <Clipboard ref={cb => {setTarget(cb)}} className="btn btn-link" data-clipboard-text={text} onSuccess={onCopySuccess}>
            <i className="fa fa-copy"></i>
          </Clipboard>
          {tooltip}
        </div>
    </div>
  </Popover>

  const onMouseEnter = event => {
    if (showIcon) return 
    setShowIcon(true)
  }

  const onMouseLeave = event => {
    setShowIcon(false)
  }

  const handlePopoverClick = event => {
    setShowPopover(!showPopover)
    setPopoverTarget(event.target)
  }
  
  return ( 
    <React.Fragment>
      { text.length>size ?
        <div className="cp">
          <span>{text.slice(0,size)}</span>
          <div className="cp-dots-help">
            <a className='help-link' onClick={handlePopoverClick} href='javascript:void(0)'>
              <i className="fa fa-ellipsis-h"></i>
            </a>
            <Overlay
              rootClose
              onHide={() => setShowPopover(false)}
              show={showPopover}
              target={popoverTarget}
              placement="top"
              container={this}
              containerPadding={20}>
                {popOver}
              </Overlay>
          </div>
        </div>
      :
        <div className="cp" onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave}>
          <span>
            {text}
          </span>
            {showIcon &&
              <div className="copy-paste-icon">
                <Clipboard ref={cb => {setTarget(cb)}} className="btn btn-link" data-clipboard-text={text} onSuccess={onCopySuccess}>
                  <i className="fa fa-copy"></i>
                </Clipboard>
                {tooltip}
              </div>
            }
        </div>
      }
    </React.Fragment>
  );
}
 
export default CopyPastePopover;