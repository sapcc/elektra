import React, { useState } from 'react';
import uniqueId from 'lodash/uniqueId'
import { OverlayTrigger, Overlay, Popover, Tooltip, Button } from 'react-bootstrap'
import Clipboard from 'react-clipboard.js';

const CopyPastePopover = ({text, size}) => {
  const [showTooltip, setShowTooltip] = useState(false)
  const [target, setTarget] = useState(null)
  const [showIcon, setShowIcon] = useState(false)

  const onCopySuccess = event => {
    setShowTooltip(true)
    setTimeout(() => setShowTooltip(false),500)
  }

  const tooltip = <Overlay
      show={showTooltip}
      placement="top"
      container={this}
      target={target}
    >
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

  return ( 
    <React.Fragment>
      { text.length>size ?
        <div className="cp">
          <span>{text.slice(0,size)}</span>
          <div className="cp-dots-help">
            <OverlayTrigger trigger="click" placement="top" rootClose overlay={popOver}>
              <a className='help-link' href='javascript:void(0)'>
                <i className="fa fa-ellipsis-h"></i>
              </a>
            </OverlayTrigger>
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