import { Link } from 'react-router-dom';
import { Popover, Overlay } from 'react-bootstrap';
import { policy } from 'policy';

export class NoShareNetworksPopover extends React.Component {
  constructor(props) {
    super(props);
    this.state = {show: false}
    this.close = this.close.bind(this)
    this.toggle = this.toggle.bind(this)
  }

  close(){
    this.setState({show: false})
  }

  toggle(e) {
    e.preventDefault();
    this.setState({ show: !this.state.show });
  }

  render(){
    let link = "/share-networks/"
    if (policy.isAllowed('shared_filesystem_storage:share_network_create')) {
      link = "/share-networks/new"
    }

    return(
      <span className={this.props.className}>
        <a className='text-warning' ref="target" href='#' onClick={this.toggle}>
          <i className='fa fa-fw fa-exclamation-triangle fa-2'></i>
        </a>

        <Overlay
          target={() => ReactDOM.findDOMNode(this.refs.target)}
          show={this.state.show}
          onHide={this.close}
          placement="top"
          >
          <Popover id="popover-no-share-networks" title="No Share Network found">
            Please <Link to={link} onClick={this.close}>create a Share Network</Link> first.
          </Popover>
        </Overlay>

      </span>
    )
  }
}
