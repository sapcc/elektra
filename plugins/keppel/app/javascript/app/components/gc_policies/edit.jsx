import { Modal, Button } from 'react-bootstrap';
import { FormErrors } from 'lib/elektra-form/components/form_errors';

export default class GCPoliciesEditModal extends React.Component {
  state = {
    show: true,
    policies: null,
    isSubmitting: false,
    apiErrors: null,
  };

  componentDidMount() {
    this.initState();
  }
  componentDidUpdate() {
    this.initState();
  }
  initState() {
    if (!this.props.account) {
      this.close();
      return;
    }
    if (this.state.policies == null) {
      const policies = this.props.account.gc_policies || [];
      this.setState({ ...this.state, policies });
    }
  }

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({ ...this.state, show: false });
    setTimeout(() => this.props.history.replace('/accounts'), 300);
  }

  setPoliciesJSON = (input) => {
    try {
      const policies = JSON.parse(input);
      this.setState({ ...this.state, policies });
    } catch (e) {
      console.log(e);
    }
  };

  handleSubmit = e => {
    e.preventDefault();
    if (this.state.isSubmitting) {
      return;
    }

    this.setState({
      ...this.state,
      isSubmitting: true,
      apiErrors: null,
    });
    const newAccount = { ...this.props.account, gc_policies: this.state.policies };
    this.props.putAccount(newAccount)
      .then(() => this.close())
      .catch(errors => {
        this.setState({
          ...this.state,
          isSubmitting: false,
          apiErrors: errors,
        });
      });
  };

  render() {
    const { account, isAdmin } = this.props;
    if (!account) {
      return;
    }
    const isEditable = isAdmin && (account.metadata || {}).readonly_in_elektra != 'true';

    const policies = this.state.policies || [];
    const { isSubmitting, errorMessage, apiErrors } = this.state;

    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Garbage collection policies for account: {account.name}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          {this.state.apiErrors && <FormErrors errors={this.state.apiErrors}/>}
          {isAdmin && !isEditable && (
            <p className='bs-callout bs-callout-warning bs-callout-emphasize'>
              The configuration for this account is read-only in this UI, probably because it was deployed by an automated process.
            </p>
          )}
          <textarea rows="10" onChange={e => this.setPoliciesJSON(e.target.value)} style={{width:"100%",resize:"vertical",fontFamily:"monospace"}} value={JSON.stringify(policies, null, 2)} />
        </Modal.Body>

        <Modal.Footer>
          {isEditable ? (
            <React.Fragment>
              <Button onClick={this.handleSubmit} bsStyle='primary'
                  disabled={isSubmitting || !isEditable}>
                {isSubmitting ? 'Saving...' : 'Save'}
              </Button>
              <Button onClick={this.close}>Cancel</Button>
            </React.Fragment>
          ) : (
            <Button onClick={this.close}>Close</Button>
          )}
        </Modal.Footer>
      </Modal>
    );
  }
}
