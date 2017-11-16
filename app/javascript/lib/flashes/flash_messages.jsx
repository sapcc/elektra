import { Alert } from './alert';
import { TransitionGroup } from 'react-transition-group';
import { FadeTransition } from 'lib/components/transitions';

let flashMessages;
export const addMessage = (message) => flashMessages.addMessage(message);
export const removeMessage = (message) => flashMessages.removeMessage(message);

export const addError = (message,options={}) =>
  flashMessages.addMessage({type: 'error', text: message, timeout: options.timeout});
export const addNotice = (message,options={}) =>
  flashMessages.addMessage({type: 'notice', text: message, timeout: options.timeout});
export const addWarning = (message,options={}) =>
  flashMessages.addMessage({type: 'warning', text: message, timeout: options.timeout});
export const addSuccess = (message,options={}) =>
  flashMessages.addMessage({type: 'success', text: message, timeout: options.timeout});

export class FlashMessages extends React.Component {
  constructor(props) {
    super(props);
    this.state = { messages: props.messages || [] };
    flashMessages = this;
  };

  addMessage(message) {
    const messages = React.addons.update(this.state.messages, { $push: [message] });
    this.setState({ messages: messages });
  };

  removeMessage(message) {
    const index = this.state.messages.indexOf(message);
    const messages = React.addons.update(this.state.messages, { $splice: [[index, 1]] });
    this.setState({ messages: messages });
  }

  render () {
    return 'Hello'
    const alerts = this.state.messages.map( (message, index) =>
      <FadeTransition key={ index } >
        <Alert message={ message } timeout={message.timeout} onClose={ () => this.removeMessage(message) } />
      </FadeTransition>
    );

    return(
      <div className="flashes-container flashes-react">
        <TransitionGroup>{ alerts }</TransitionGroup>
      </div>
    );
  }
}

FlashMessages.propTypes = {
  messages: React.PropTypes.array
};
