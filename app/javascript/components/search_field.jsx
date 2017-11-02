import { Popover, OverlayTrigger } from 'react-bootstrap';

let counter = 0;

export default ({id,text,onChange,placeholder}) => {
  const infoText = (
    <Popover id={`search_field_${id || counter++}`}>
      {text}
    </Popover>
  );

  return (
    <div className="pull-left">
      <div className="has-feedback has-feedback-searchable">
        <input type="text" className="form-control" placeholder={placeholder} onChange={(e) => onChange(e.target.value)}/>
          <span className="form-control-feedback"><i className="fa fa-search"></i></span>
        </div>
        <div className="has-feedback-help">
          <OverlayTrigger trigger="click" placement="top" rootClose overlay={infoText}>
            <a className='help-link' href='#'>
              <i className="fa fa-question-circle"></i>
            </a>
          </OverlayTrigger>
      </div>
    </div>
  )
}
