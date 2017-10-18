import { Modal, Button } from 'react-bootstrap';

const Deferred = function() {
  this.promise = new Promise((function(resolve, reject) {
    this.resolve = resolve;
    this.reject = reject;
  }).bind(this));

  this.then = this.promise.then.bind(this.promise);
  this.catch = this.promise.catch.bind(this.promise);
};

export class Dialog extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {show:false}
    this.abort = this.abort.bind(this);
    this.confirm = this.confirm.bind(this);
  }

  static defaultProps = {
    confirmLabel: 'Yes',
    abortLabel: 'No',
    showAbortButton: true
  }

  abort() {
    this.setState({show: false}, () => this.promise.reject())
  }

  confirm() {
    this.setState({show: false}, () => this.promise.resolve())
  }

  componentDidMount() {
    // this.promise = new $.Deferred();
    this.promise = new Deferred()
    this.setState({show: true}, () =>
      ReactDOM.findDOMNode(this.refs.confirm).focus()
    )
  }

  render(){
    return (
      <Modal show={this.state.show} onExited={this.props.onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton={false}>
          <Modal.Title id="contained-modal-title-lg">
            <i className={`dialog-title-icon ${this.props.type}`}></i>
            {this.props.type.replace(/\b\w/g, l => l.toUpperCase())}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          { this.props.title &&
            <h4>
              { this.props.title }
            </h4>
          }
          { this.props.message && <p>{ this.props.message }</p> }
        </Modal.Body>
        <Modal.Footer>
          { this.props.showAbortButton && <Button onClick={this.abort}>{this.props.abortLabel}</Button>}
          <Button bsStyle='primary' onClick={this.confirm} ref='confirm'>{this.props.confirmLabel}</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
