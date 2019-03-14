import { Modal, Button } from 'react-bootstrap';
import { FormErrors } from 'lib/elektra-form/components/form_errors';

import { t } from '../../utils';
import { Scope } from '../../scope';
import { Unit } from '../../unit';

export default class DetailsModal extends React.Component {
  state = {
    //This will be set to false by this.close().
    show: true,
    //This contains the quota/usage data for the subscopes (for domain level,
    //the domain's projects; for cluster level, the cluster's domains).
    subscopes: null,
    isFetching: false,
    //Unexpected errors returned from the Limes API, if any.
    apiErrors: null,
  };

  componentWillReceiveProps(nextProps) {
    this.fetchSubscopes(nextProps);
  }

  componentDidMount() {
    this.fetchSubscopes(this.props);
  }

  //This gets called once to initialize the list of subscopes.
  fetchSubscopes = (props) => {
    //do this only once
    if (this.state.subscopes || this.state.isFetching) {
      return;
    }

    this.setState({
      ...this.state,
      isFetching: true,
    });
    props.listSubscopes(props.scopeData, props.category.serviceType, props.resourceName)
      .then(this.receiveSubscopes)
      .catch(response => this.handleAPIErrors(response.errors));
  }

  //This gets called by fetchSubscopes() on success.
  receiveSubscopes = (subscopes) => {
    this.setState({
      ...this.state,
      subscopes,
      isFetching: false,
    });
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  //This gets called when a PUT request to Limes fails.
  handleAPIErrors = (errors) => {
    this.setState({
      ...this.state,
      isFetching: false,
      apiErrors: errors,
    });
  };

  render() {
    const { categoryName, resourceName } = this.props;
    const { isFetching, apiErrors } = this.state;

    const scope = new Scope(this.props.scopeData);
    const Resource = scope.resourceComponent();

    //these props are passed on to the Resource children verbatim
    const forwardProps = {
      flavorData:   this.props.flavorData,
      scopeData:    this.props.scopeData,
      metadata:     this.props.metadata,
      categoryName: this.props.categoryName,
      resource:     this.props.resource,
    };

    //NOTE: className='resources' on Modal ensures that plugin-specific CSS rules get applied
    return (
      <Modal className='resources' backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Details for: {`${t(categoryName)} > ${t(resourceName)}`}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <Resource captionOverride='Quota usage' {...forwardProps} />
          <Resource captionOverride='Resource usage' showUsage={true} {...forwardProps} />

          {isFetching ? <p>
            <span className='spinner'/> Loading {scope.sublevel()}s...
          </p> : <React.Fragment>
          </React.Fragment>}
        </Modal.Body>

        <Modal.Footer>
          {apiErrors && <FormErrors errors={apiErrors}/>}
          <Button onClick={this.close}>Done</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
