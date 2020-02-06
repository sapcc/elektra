import { Modal, Button } from 'react-bootstrap';
import { FormErrors } from 'lib/elektra-form/components/form_errors';

import RBACPoliciesEditRow from './row';

export default class RBACPoliciesEditModal extends React.Component {
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
      const { rbac_policies: policies } = this.props.account;
      this.setState({ ...this.state, policies });
    }
  }

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({ ...this.state, show: false });
    setTimeout(() => this.props.history.replace('/accounts'), 300);
  }

  setRepoRegex = (idx, input) => {
    const policies = [ ...this.state.policies ];
    policies[idx] = { ...policies[idx], match_repository: input };
    this.setState({ ...this.state, policies });
  }
  setUserRegex = (idx, input) => {
    const policies = [ ...this.state.policies ];
    policies[idx] = { ...policies[idx], match_username: input };
    this.setState({ ...this.state, policies });
  }
  setPermissions = (idx, input) => {
    const policies = [ ...this.state.policies ];
    policies[idx] = { ...policies[idx], permissions: input.split(',') };
    this.setState({ ...this.state, policies });
  }
  removePolicy = (idx, input) => {
    const policies = this.state.policies.filter((p, index) => idx != index);
    this.setState({ ...this.state, policies });
  };
  addPolicy = e => {
    const newPolicy = { match_repository: '', match_username: '', permissions: [] };
    this.setState({ ...this.state,
      policies: [ ...this.state.policies, newPolicy ],
    });
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
    const newAccount = { ...this.props.account, rbac_policies: this.state.policies };
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

    const policies = this.state.policies || [];
    const { isSubmitting, errorMessage, apiErrors } = this.state;

    const { setRepoRegex, setUserRegex, setPermissions, removePolicy } = this;
    const commonPropsForRow = { isAdmin, setRepoRegex, setUserRegex, setPermissions, removePolicy };

    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Access policies for account: {account.name}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <React.Fragment>
            {this.state.apiErrors && <FormErrors errors={this.state.apiErrors}/>}
            <table className='table'>
              <thead>
                <tr>
                  <th className='col-md-4'>Repositories matching</th>
                  <th className='col-md-4'>User names matching</th>
                  <th className='col-md-3'>Permissions</th>
                  <th className='col-md-1'>
                    {isAdmin && (
                      <button className='btn btn-sm btn-default' onClick={this.addPolicy}>
                        Add policy
                      </button>
                    )}
                  </th>
                </tr>
              </thead>
              <tbody>
                {policies.map((policy, idx) => (
                  <RBACPoliciesEditRow {...commonPropsForRow}
                    key={idx} index={idx} policy={policy}
                  />
                ))}
                { policies.length == 0 && (
                  <tr>
                    <td colSpan='4' className='text-muted text-center'>No entries</td>
                  </tr>
                )}
              </tbody>
            </table>
            {policies.length > 0 && (
              <p>
                Matches use the <a href='https://golang.org/pkg/regexp/syntax/'>Go regex syntax</a>. Leading <code>^</code> and trailing <code>$</code> anchors are always added automatically. User names are in the format <code>user@userdomain/project@projectdomain</code>.
              </p>
            )}
          </React.Fragment>
        </Modal.Body>

        <Modal.Footer>
          {isAdmin ? (
            <React.Fragment>
              <Button onClick={this.handleSubmit} bsStyle='primary'
                  disabled={isSubmitting || !isAdmin}>
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
