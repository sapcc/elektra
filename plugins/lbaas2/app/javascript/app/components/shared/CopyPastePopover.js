import React, { useState, useEffect } from 'react';
import uniqueId from 'lodash/uniqueId'
import { Overlay, Popover, Tooltip } from 'react-bootstrap'
import Clipboard from 'react-clipboard.js';


/**
 * 
 * text --> text to show
 * size --> chars numbers to display
 * sliceType --> text sliced from END OR MIDDLE (default: END)
 * shouldClose --> Popover if displayed will be closed
 */
const CopyPastePopover = ({text, size, sliceType, shouldClose, bsClass}) => {
  const [showTooltip, setShowTooltip] = useState(false)
  const [target, setTarget] = useState(null)
  const [showIcon, setShowIcon] = useState(false)
  const [showPopover, setShowPopover] = useState(false)
  const [popoverTarget, setPopoverTarget] = useState(null)
  let ref = React.useRef(null);
  const baseClass = bsClass || "cp"

  useEffect(() => {
    if (shouldClose && showPopover) setShowPopover(false)
  },[shouldClose])

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

  const textSliced = () => {
    if (sliceType && sliceType == "MIDDLE") {
      const first = size/2
      const second = size-first
      const firstPeace = text.slice(0,first)
      const secondPeace = text.slice(text.length-second,text.length)
      return [firstPeace, secondPeace]
    } 
    return [text.slice(0,size), ""]
  }

  const popoverOverlay = <React.Fragment>
    <a className='help-link' onClick={handlePopoverClick} href='javascript:void(0)'>
      <i className="fa fa-ellipsis-h"></i>
    </a>
    <Overlay
      ref={r => (ref = r)} 
      onHide={() => setShowPopover(false)}
      show={showPopover}
      target={popoverTarget}
      placement="top"
      container={this}
      containerPadding={20}>
        {popOver}
    </Overlay>
  </React.Fragment>

  return ( 
    <React.Fragment>
      { text.length>size ?
        <div className={baseClass}>
          <span>{textSliced()[0]}</span>
          <div className="cp-dots-help">
            {popoverOverlay}
          </div>
          <span>{textSliced()[1]}</span>
        </div>
      :
        <div className={baseClass} onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave}>
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