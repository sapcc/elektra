import { Popover, OverlayTrigger } from 'react-bootstrap';

let counter = 0;

/**
 * This component implements a serach field.
 * Usage: <SearchField placeholder='Name' text='Search by name' onChange={(term) => handleSearch}/>
 **/
export class SearchField extends React.Component {
  state = {
    searchTerm: ''
  }

  infoText =
    <Popover id={`search_field_${this.props.id || counter++}`}>
      {this.props.text}
    </Popover>

  onChangeTerm = (e) => {
    const value = e.target.value || ''
    this.setState({searchTerm: value}, () => this.props.onChange(value))
  }

  reset = (e) => {
    e.preventDefault()
    this.setState({searchTerm: ''}, () => this.props.onChange(''))
  }

  componentWillReceiveProps = (nextProps) => {
    // console.log('componentWillReceiveProps',nextProps)
    if (nextProps.value!=null) this.setState({searchTerm: nextProps.value})
  }

  componentDidMount = () => {
    // console.log('componentDidMount',this.props)
    if (this.props.value) this.setState({searchTerm: this.props.value})
  }


  render() {
    const empty = this.state.searchTerm.trim().length==0
    const showSearchIcon = (this.props.searchIcon != false)
    let iconClassName = empty ? (showSearchIcon ? 'fa fa-search' : '') : 'fa fa-times-circle'
    if (this.props.isFetching) iconClassName = 'spinner'

    return (
      <React.Fragment>
        <div className='has-feedback has-feedback-searchable'>
          <input
            type="text"
            className="form-control"
            value={this.state.searchTerm}
            placeholder={this.props.placeholder}
            onChange={this.onChangeTerm}
          />
          <span
            className={`form-control-feedback ${!empty && 'not-empty'}`}
            onClick={(e) => !empty && this.reset(e)}>
            <i className={iconClassName}/>
          </span>
        </div>
        {this.props.text &&
          <div className="has-feedback-help">
            <OverlayTrigger trigger="click" placement="top" rootClose overlay={this.infoText}>
              <a className='help-link' href='javascript:void(0)'>
                <i className="fa fa-question-circle"></i>
              </a>
            </OverlayTrigger>
          </div>
        }
      </React.Fragment>
    )
  }
}
