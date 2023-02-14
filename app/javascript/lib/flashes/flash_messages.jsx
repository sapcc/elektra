import React from "react"
import PropTypes from "prop-types"
import { Alert } from "./alert"
import { TransitionGroup } from "react-transition-group"
import { FadeTransition } from "lib/components/transitions"

let flashMessages
export const addMessage = (message) => {
  if (flashMessages) {
    flashMessages.addMessage(message)
  }
}
export const removeMessage = (message) => {
  if (flashMessages) {
    flashMessages.removeMessage(message)
  }
}

export const addError = (message, options = {}) => {
  if (flashMessages) {
    flashMessages.addMessage({
      type: "error",
      text: message,
      timeout: options.timeout,
    })
  }
}
export const addNotice = (message, options = {}) => {
  if (flashMessages) {
    flashMessages.addMessage({
      type: "notice",
      text: message,
      timeout: options.timeout,
    })
  }
}
export const addWarning = (message, options = {}) => {
  if (flashMessages) {
    flashMessages.addMessage({
      type: "warning",
      text: message,
      timeout: options.timeout,
    })
  }
}
export const addSuccess = (message, options = {}) => {
  if (flashMessages) {
    flashMessages.addMessage({
      type: "success",
      text: message,
      timeout: options.timeout,
    })
  }
}

export class FlashMessages extends React.Component {
  constructor(props) {
    super(props)
    this.state = { messages: props.messages || [] }
    flashMessages = this
  }

  addMessage(message) {
    let messages = this.state.messages.slice()
    messages.push(message)
    this.setState({ messages: messages })
  }

  removeMessage(message) {
    const index = this.state.messages.indexOf(message)
    if (index > -1) {
      const messages = this.state.messages.slice()
      messages.splice(index, 1)
      this.setState({ messages: messages })
    }
  }

  render() {
    const alerts = this.state.messages.map((message, index) => (
      <FadeTransition key={index}>
        <Alert
          message={message}
          timeout={message.timeout}
          onClose={() => this.removeMessage(message)}
        />
      </FadeTransition>
    ))

    return (
      <div className="flashes-container flashes-react">
        <TransitionGroup>{alerts}</TransitionGroup>
      </div>
    )
  }
}

FlashMessages.propTypes = {
  messages: PropTypes.array,
}
