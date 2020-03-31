import React from 'react';
import uniqueId from 'lodash/uniqueId'
import { OverlayTrigger, Popover } from 'react-bootstrap'

const CopyPastePopover = ({text, size}) => {

  const handleCopy = (e) => {
    e.preventDefault();
    
  }

  
  const textId = uniqueId("copy-text-")
  const clipboard = new ClipboardJS(`#${textId}`);
  clipboard.on('success', function(e) {
    console.info('Action:', e.action);
    console.info('Text:', e.text);
    console.info('Trigger:', e.trigger);
    e.clearSelection();
  });

  clipboard.on('error', function(e) {
    console.error('Action:', e.action);
    console.error('Trigger:', e.trigger);
  });

  const popOver =  <Popover id={uniqueId("help-popover-")}>
    <div className="lbaas2">
        <span id={textId}>{text}</span>
        <div className="text-right">
          <a className='help-link' href='javascript:void(0)'>
            <i className="fa fa-copy"></i>
          </a>
        </div>
    </div>
  </Popover>

  return ( 
    <React.Fragment>
      { text.length>size ?
        <div className="display-flex">
          <span>{text.slice(0,size)}</span>
          <div className="dots-help">
            <OverlayTrigger trigger="click" placement="top" rootClose 
              overlay={popOver}>
              <a className='help-link' href='javascript:void(0)'>
                <i className="fa fa-ellipsis-h"></i>
              </a>
            </OverlayTrigger>
          </div>
        </div>
      :
        <div className="display-flex">
          <span>{text}</span>
          <div className="copy-paste-help">
            <a className='help-link' href='javascript:void(0)' onClick={handleCopy}>
              <i className="fa fa-copy"></i>
            </a>
          </div>
        </div>
      }
    </React.Fragment>
  );
}
 
export default CopyPastePopover;