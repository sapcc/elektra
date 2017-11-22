import { Popover, OverlayTrigger } from 'react-bootstrap';

let counter = 0;

export default class SearchField extends React.Component {
  constructor(props) {
    super(props);
    this.state = {term: ''}
    this.infoTextPopover = this.infoTextPopover.bind(this)
    this.onChange = this.onChange.bind(this)
    this.isTermPresent = this.isTermPresent.bind(this)
    this.loadNext = this.loadNext.bind(this)
  }

  isTermPresent(){
    return (this.state.term || '').trim().length>0
  }

  loadNext(props){
    if(this.isTermPresent() && props.hasNext && !props.isFetching && props.loadNext) {
      props.loadNext()
    }
  }

  componentWillReceiveProps(nextProps) {
    this.loadNext(nextProps)
  }

  infoTextPopover() {
    return(
      <Popover id={`search_field_${this.props.id || counter++}`}>
        {this.props.text}
      </Popover>
    )
  }

  onChange(term){
    this.setState({term}, () => {
      this.loadNext(this.props)
      this.props.onChange(term)
    })
  }

  render() {
    return(
      <div className="pull-left">
        <div className="has-feedback has-feedback-searchable">
          <input
            type="text"
            className="form-control"
            placeholder={this.props.placeholder}
            onChange={(e) => this.onChange(e.target.value)}/>
          <span className="form-control-feedback"><i className="fa fa-search"></i></span>
        </div>
        <div className="has-feedback-help">
          <OverlayTrigger trigger="click" placement="top" rootClose overlay={this.infoTextPopover()}>
            <a className='help-link' href='javascript:void(0)'>
              <i className="fa fa-question-circle"></i>
            </a>
          </OverlayTrigger>
        </div>
      </div>
    )
  }

}
