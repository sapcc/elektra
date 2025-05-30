import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import React from "react"
import { apiStateIsDeleting } from "../utils"

export default class RBACPoliciesEditModal extends React.Component {
  state = {
    show: true,
  }

  close = (e) => {
    if (e) {
      e.stopPropagation()
    }
    this.setState({ ...this.state, show: false })
    setTimeout(() => this.props.history.replace("/accounts"), 300)
  }

  validate = (values) => {
    return true
  }

  onSubmit = ({ required_labels: requiredLabelsStr }) => {
    const newAccount = {
      ...this.props.account,
      validation: {
        required_labels: requiredLabelsStr
          .split(",")
          .map((l) => l.trim())
          .filter((l) => l != ""),
      },
    }
    return this.props.putAccount(newAccount).then(() => this.close())
  }

  render() {
    const { account, isAdmin } = this.props
    if (!account || apiStateIsDeleting(account?.state)) {
      return null
    }

    const initialValues = {
      required_labels: ((account.validation || {}).required_labels || []).join(
        ", "
      ),
    }

    return (
      <Modal
        backdrop="static"
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Validation rules for account: {this.props.account.name}
          </Modal.Title>
        </Modal.Header>

        <Form
          className="form form-horizontal"
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}
        >
          <Modal.Body>
            <Form.ElementHorizontal
              label="Required labels"
              name="required_labels"
            >
              <Form.Input
                elementType="input"
                type="text"
                name="required_labels"
                readOnly={!isAdmin}
              />
              <p className="form-control-static">
                When set, only images that have all these labels can be pushed
                into the account. Labels can be set on Docker images by adding{" "}
                <a href="https://docs.docker.com/engine/reference/builder/#label">
                  LABEL commands
                </a>{" "}
                to the Dockerfile.
              </p>
            </Form.ElementHorizontal>
          </Modal.Body>

          {isAdmin ? (
            <Modal.Footer>
              <Form.SubmitButton label="Save" />
              <Button onClick={this.close}>Cancel</Button>
            </Modal.Footer>
          ) : (
            <Modal.Footer>
              <Button onClick={this.close}>Close</Button>
            </Modal.Footer>
          )}
        </Form>
      </Modal>
    )
  }
}
