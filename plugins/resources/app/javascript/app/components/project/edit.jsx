import { Modal, Button } from 'react-bootstrap';

import { byUIString, t } from '../../utils';
import ProjectResource from '../../components/project/resource';
import { Unit } from '../../unit';

export default class ProjectEditModal extends React.Component {
  state = {
    //This will be set to false by this.close().
    show: true,
    //The `inputTexts` object contains the current contents of all input fields
    //in this form.
    inputTexts: null,
    //The `inputValues` object contains the parsed numerical quota values for
    //all input fields in this form. This is different from `inputTexts`
    //because an `inputText` may temporarily not parse correctly while the user
    //is still entering it.
    inputValues: null,
  }

  componentWillReceiveProps(nextProps) {
    this.initializeValuesIfNecessary(nextProps);
  }

  componentDidMount() {
    this.initializeValuesIfNecessary(this.props);
  }

  initializeValuesIfNecessary = (props) => {
    //do this only once
    if (this.state.inputValues) {
      return;
    }
    //do this only when we have project data
    const { resources } = props.category || {};
    if (!resources) {
      return;
    }

    //initialize the state of the input form
    const inputValues = {};
    const inputTexts = {};
    for (let res of resources) {
      const unit = new Unit(res.unit);
      inputValues[res.name] = res.quota;
      inputTexts[res.name] = unit.format(res.quota);
    }
    this.setState({...this.state, inputValues, inputTexts});
  }

  //This gets called by the input fields' onChange event.
  handleInput = (resourceName, inputText) => {
    const newState = { ...this.state };
    newState.inputTexts = { ...this.state.inputTexts };
    newState.inputTexts[resourceName] = inputText;
    this.setState(newState);

    //TODO: parse value and update inputValues on success
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  handleSubmit = (values) => {
    this.close();
  }

  render() {
    //these props are passed on to the ProjectResource children verbatim
    const forwardProps = {
      flavorData: this.props.flavorData,
      metadata:   this.props.metadata,
    };

    const { category, categoryName } = this.props;

    //NOTE: className='resources' on Modal ensures that plugin-specific CSS rules get applied
    return (
      <Modal className='resources' backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Edit Project Quota: {t(categoryName)}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          <div className='row edit-quota-form-header'>
            <div className='col-md-offset-2 col-md-5'><strong>Live Preview</strong></div>
            <div className='col-md-5'><strong>New Quota</strong></div>
          </div>
          {this.state.inputValues && category.resources.sort(byUIString).map(res => (
            <ProjectResource
              key={res.name} resource={res} {...forwardProps}
              editQuotaValue={this.state.inputValues[res.name]}
              editQuotaText={this.state.inputTexts[res.name]}
              handleInput={this.handleInput}
            />
          ))}
        </Modal.Body>
      </Modal>
    );
  }
}
