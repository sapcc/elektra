import { Popover, OverlayTrigger } from 'react-bootstrap';

let counter = 0;

export default ({id,text,onChange,placeholder}) => {
  const infoText = (
    <Popover id={`search_field_${id || counter++}`}>
      {text}
    </Popover>
  );

  const onChangeTerm = (e) => {
    const term = escape(e.target.value || '')
    onChange(term)
  }

  return (
    <React.Fragment>
      <div className="has-feedback has-feedback-searchable">
        <input type="text" className="form-control" placeholder={placeholder} onChange={onChangeTerm}/>
        <span className="form-control-feedback"><i className="fa fa-search"></i></span>
      </div>
      <div className="has-feedback-help">
        <OverlayTrigger trigger="click" placement="top" rootClose overlay={infoText}>
          <a className='help-link' href='javascript:void(0)'>
            <i className="fa fa-question-circle"></i>
          </a>
        </OverlayTrigger>
      </div>
    </React.Fragment>
  )
}
