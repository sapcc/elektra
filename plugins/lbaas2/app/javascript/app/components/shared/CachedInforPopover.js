import React, { useState } from 'react';
import { Overlay, Button, Popover } from 'react-bootstrap'


const LbPopover = ({popoverId, buttonName, title, content}) => {
  console.log("--> RENDER LbPopover")

  const [show, setShow] = useState(false)
  const [target, setTarget] = useState(null)

  const handleClick = event => {
    setShow(!show)
    setTarget(event.target)
  }

  return (    
    <div>
      <Button bsStyle="link" onClick={handleClick} >{buttonName}</Button>
      <Overlay
        rootClose
        onHide={() => setShow(false)}
        show={show}
        target={target}
        placement="bottom"
        container={this}
        containerPadding={20}
      >
          <Popover bsClass="lbaas2 lb-popover popover" id={popoverId} title={title}>
            <div className="lb-content">
              {content}
            </div>
            <div className="lb-footer">
              Preview from cache
            </div>
          </Popover>
      </Overlay>
    </div>

  )
}

export default LbPopover