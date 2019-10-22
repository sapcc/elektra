import { Modal, Button } from 'react-bootstrap';
import { FormErrors } from 'lib/elektra-form/components/form_errors';

import { sendQuotaRequest } from '../actions/elektra';
import { byLeaderAndName, t, buttonCaption } from '../utils';
import { Scope } from '../scope';
import { Unit } from '../unit';

export default class EditModal extends React.Component {
  state = {
    //This will be set to false by this.close().
    show: true,
    //The `inputs` object contains the editing state for each input field. The
    //key is the resource name.
    inputs: null,
    //Indicates whether new values have been entered, but not yet parsed by
    //parseInputs().
    hasNewInputs: false,
    //Indicates whether a "Check" or "Submit" is in progress.
    isChecking: false,
    isSubmitting: false,
    //Unexpected errors returned from the Limes API, if any.
    apiErrors: null,
  }

  //NOTE: These fields hold active timers (as started by setTimeout()). This is
  //not part of `state` because starting or stopping timers does not cause a
  //redraw, and `render()` does not need to mess with the timers.
  asyncParseInputsTimer = null;

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.initializeValuesIfNecessary(nextProps);
  }

  componentDidMount() {
    this.initializeValuesIfNecessary(this.props);
  }

  initializeValuesIfNecessary = (props) => {
    //do this only once
    if (this.state.inputs) {
      return;
    }
    //do this only when we have resource data
    const { resources } = props.category || {};
    if (!resources) {
      return;
    }

    //initialize the state of the input form
    const inputs = {};
    const hasResource = {};
    for (let res of resources) {
      const unit = new Unit(res.unit);
      inputs[res.name] = {
        value: res.quota,
        text: unit.format(res.quota, { ascii: true }),
      };
      hasResource[res.name] = true;
    }
    for (let res of resources) {
      //can only use scaling relations between resources in the same service+category
      if (res.scales_with && res.scales_with.service_type == props.category.serviceType) {
        if (hasResource[res.scales_with.resource_name]) {
          inputs[res.name].isFollowing = true;
        }
      }
    }

    this.setState({...this.state, inputs });
  }

  //This gets called by the input fields' onChange event.
  handleInput = (resourceName, inputText) => {
    if (this.state.isChecking || this.state.isSubmitting) {
      return;
    }

    //update inputTexts immediately
    const newState = { ...this.state, hasNewInputs: true };
    newState.inputs = { ...this.state.inputs };
    const oldInputState = this.state.inputs[resourceName];
    newState.inputs[resourceName] = { ...oldInputState,
      text: inputText,
      isFollowing: false, //editing a quota breaks the followership
    };

    //also, clear away:
    //- all check results (to convert the "Submit" button back to "Check")
    //- the animation attributes
    for (let res of this.props.category.resources) {
      if (newState.inputs[res.name].checkResult) {
        newState.inputs[res.name] = { ...newState.inputs[res.name] };
        delete newState.inputs[res.name].checkResult;
      }
      if (newState.inputs[res.name].isFlashing) {
        newState.inputs[res.name] = { ...newState.inputs[res.name], isFlashing: false };
      }
    }

    this.setState(newState);

    //do not attempt to update inputs[].value etc. immediately; wait until the
    //user has stopped typing
    if (this.asyncParseInputsTimer) {
      window.clearTimeout(this.asyncParseInputsTimer);
    }
    this.asyncParseInputsTimer = setTimeout(this.parseInputs, 1000);
  };

  //This gets called by the "Reset" button that may appear alongside an input field.
  handleResetFollower = (resourceName) => {
    if (this.state.isChecking || this.state.isSubmitting) {
      return;
    }

    this.parseInputs((state) => {
      state.inputs[resourceName].isFollowing = true;
    });
  };

  //Parses the user's quota inputs. This gets called asynchronously by
  //handleInput() after the user has stopped typing, but is also triggered
  //eagerly by events on the input field (e.g. Tab/Enter keys or mouse-out)
  //following a "do what I mean" strategy.
  parseInputs = (additionalStateChanger=null) => {
    //do not auto-trigger this again unless desired
    if (this.asyncParseInputsTimer) {
      window.clearTimeout(this.asyncParseInputsTimer);
      this.asyncParseInputsTimer = null;
    }
    if (!this.state.hasNewInputs && !additionalStateChanger) {
      return;
    }

    const newState = { ...this.state, inputs: {}, hasNewInputs: false };
    const scope = new Scope(this.props.scopeData);
    for (let res of this.props.category.resources) {
      const unit = new Unit(res.unit);
      const oldInput = this.state.inputs[res.name];
      const input = { text: oldInput.text, isFollowing: oldInput.isFollowing };
      newState.inputs[res.name] = input;

      //if the user has not modified the input text, always use the original
      //value (this may be different from `unit.parse(inputText)` if the
      //formatting removed some decimal places)
      const originalText = unit.format(res.quota, { ascii: true });
      if (originalText == input.text) {
        input.value = res.quota;
        continue;
      }

      //attempt to parse the user's input
      const parsedValue = unit.parse(input.text);
      if (parsedValue.error) {
        //parse error -> continue to show the previous value on the bar
        input.value = oldInput.value;
        input.error = parsedValue.error;
      } else {
        input.value = parsedValue;
        input.error = scope.validateQuotaInput(parsedValue, res);
      }
    }

    //this hook is used by handleResetFollower() to reset the isFollowing flag
    //on a resource
    if (additionalStateChanger) {
      additionalStateChanger(newState);
    }

    //follower resources have their values computed automatically
    for (let res of this.props.category.resources) {
      if (!newState.inputs[res.name].isFollowing) {
        continue;
      }
      const baseResName = res.scales_with.resource_name;
      const baseRes = this.props.category.resources.find(res => res.name == baseResName);
      const baseInput = newState.inputs[baseResName];

      const previousValue = newState.inputs[res.name].value;

      //do not auto-derive values while the base resource has an input error
      if (baseInput.error) {
        continue;
      }
      const delta = res.scales_with.factor * (baseInput.value - baseRes.quota);
      const value = Math.max(res.usage, res.quota + delta); //`delta` may be negative!
      newState.inputs[res.name] = {
        value: value,
        text: (new Unit(res.unit)).format(value, { ascii: true }),
        isFollowing: true,
        isFlashing: value != previousValue,
      };
    }

    this.setState(newState);
  };

  close = (e) => {
    if (e) { e.stopPropagation(); }
    this.setState({show: false});
    setTimeout(() => this.props.history.replace('/'), 300);
  }

  //This gets called by the "Check" button in the footer.
  handleCheck = () => {
    if (this.state.isChecking || this.state.isSubmitting) {
      return;
    }
    const scope = new Scope(this.props.scopeData);

    const resourcesForRequest = [];
    for (let res of this.props.category.resources) {
      const input = this.state.inputs[res.name];
      if (input.error) {
        return;
      }
      resourcesForRequest.push({ name: res.name, quota: input.value });
    }
    const requestBody = {};
    requestBody[scope.level()] = {
      services: [{
        type: this.props.category.serviceType,
        resources: resourcesForRequest,
      }],
    };

    this.setState({
      ...this.state,
      isChecking: true,
      apiErrors: null,
    });
    this.props.simulateSetQuota(this.props.scopeData, requestBody)
      .then(this.handleCheckResponse)
      .catch(response => this.handleAPIErrors(response.errors));
  };

  //This gets called with the response from the POST /simulate-put request.
  handleCheckResponse = (response) => {
    let { success, unacceptable_resources: unacceptableResources } = response.data;
    if (success) {
      unacceptableResources = [];
    }

    const newInputs = { ...this.state.inputs };
    const resUnitByName = {};
    for (let res of this.props.category.resources) {
      newInputs[res.name].checkResult = { success: true };
      resUnitByName[res.name] = new Unit(res.unit);
    }
    for (let error of unacceptableResources) {
      const input = newInputs[error.resource_name];
      switch (error.status) {
        case 403:
          if (error.max_acceptable_quota) {
            const limit = resUnitByName[error.resource_name].format(error.max_acceptable_quota);
            if (this.props.isForeignScope) {
              input.checkResult = { unacceptable: `Raising beyond ${limit} not allowed` };
            } else {
              input.checkResult = { requestRequired: `Raising beyond ${limit} requires approval` };
            }
          } else {
            if (this.props.isForeignScope) {
              input.checkResult = { unacceptable: `Raising quotas not allowed` };
            } else {
              input.checkResult = { requestRequired: `Raising quotas requires approval` };
            }
          }
          break;
        case 409:
          if (error.max_acceptable_quota != null && !this.props.isForeignScope) {
            //This case happens when we could raise project quota with
            //auto-approval, but the domain quota is too low. We don't show a
            //limit number because the concrete limit depends on the domain
            //quota which the current user cannot interact with, so showing it
            //would be unnecessarily confusing.
            input.checkResult = { requestRequired: `Requires approval by domain admin` };
          } else {
            input.checkResult = { unacceptable: error.message };
          }
          break;
        default:
          input.checkResult = { unacceptable: error.message };
          break;
      }
    }

    this.setState({
      ...this.state,
      inputs: newInputs,
      isChecking: false,
      apiErrors: null,
    });
  };

  //This gets called by the "Check" button in the footer.
  handleSubmit = () => {
    if (this.state.isChecking || this.state.isSubmitting) {
      return;
    }
    const scope = new Scope(this.props.scopeData);

    const resourcesForLimes = [];
    const resourcesForElektra = [];
    for (let res of this.props.category.resources) {
      const input = this.state.inputs[res.name];
      if (input.error) {
        return;
      }
      const cr = input.checkResult;
      if (!cr || cr.unacceptable) {
        return;
      }
      if (cr.requestRequired) {
        resourcesForElektra.push({ name: res.name, quota: input.value });
      } else if (input.value != res.quota) {
        resourcesForLimes.push({ name: res.name, quota: input.value });
      }
    }

    const promises = [];

    if (resourcesForElektra.length > 0) {
      const elektraRequestBody = {};
      elektraRequestBody[scope.level()] = {
        services: [{
          type: this.props.category.serviceType,
          resources: resourcesForElektra,
        }],
      };
      promises.push(sendQuotaRequest(this.props.scopeData, elektraRequestBody));
    }

    if (resourcesForLimes.length > 0) {
      const limesRequestBody = {};
      limesRequestBody[scope.level()] = {
        services: [{
          type: this.props.category.serviceType,
          resources: resourcesForLimes,
        }],
      };
      promises.push(this.props.setQuota(this.props.scopeData, limesRequestBody));
    }

    this.setState({
      ...this.state,
      isSubmitting: true,
      apiErrors: null,
    });
    Promise.all(promises).then(() => {
      // update main view to show new quota values
      this.props.fetchData(this.props.scopeData);
      this.close();
    }).catch(response => this.handleAPIErrors(response.errors));
  };

  //This gets called when a PUT request to Limes or Elektra fails.
  handleAPIErrors = (errors) => {
    this.setState({
      ...this.state,
      isChecking: false,
      isSubmitting: false,
      apiErrors: errors,
    });
  };

  render() {
    //these props are passed on to the Resource children verbatim
    const forwardProps = {
      flavorData:   this.props.flavorData,
      scopeData:    this.props.scopeData,
      metadata:     this.props.metadata,
      categoryName: this.props.categoryName,
      canEdit:      this.props.canEdit,
    };

    const { category, categoryName } = this.props;
    const scope = new Scope(this.props.scopeData);
    const Resource = scope.resourceComponent();

    let hasInputErrors = false;
    let canSubmit = true;
    let hasCheckErrors = false;
    let requestRequiredCount = 0;
    for (let res of category.resources) {
      const input = (this.state.inputs || {})[res.name] || {};
      if (input.error) {
        hasInputErrors = true;
      }
      if (!input.checkResult) {
        canSubmit = false;
      }
      const checkResult = input.checkResult || {};
      if (checkResult.unacceptable) {
        hasCheckErrors = true;
      }
      if (checkResult.requestRequired) {
        requestRequiredCount++;
      }
    }
    const showSubmitButton = canSubmit && !hasCheckErrors;
    const ajaxInProgress = this.state.isChecking || this.state.isSubmitting;

    let footerMessage = undefined;
    if (showSubmitButton && requestRequiredCount > 0) {
      const countStr = requestRequiredCount == 1 ? '1 request' : `${requestRequiredCount} requests`;
      const nextScope = scope.isProject() ? 'domain' : 'cloud';
      footerMessage = <span className='request-explanation'>
        When you click "Submit", {countStr} will be sent to the {nextScope} resource admins for approval.
      </span>;
    }

    //NOTE: className='resources' on Modal ensures that plugin-specific CSS rules get applied
    return (
      <Modal className='resources' backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Edit {scope.level()} quota: {t(categoryName)}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body>
          {this.state.apiErrors && <FormErrors errors={this.state.apiErrors}/>}
          <div className='row edit-quota-form-header'>
            <div className='col-md-offset-6 col-md-6'><strong>New Quota</strong></div>
          </div>
          {this.state.inputs && category.resources.sort(byLeaderAndName).map(res => (
            <Resource
              key={res.name} resource={res} {...forwardProps}
              edit={this.state.inputs[res.name]}
              disabled={ajaxInProgress}
              handleInput={this.handleInput}
              handleResetFollower={this.handleResetFollower}
              triggerParseInputs={this.parseInputs}
            />
          ))}
        </Modal.Body>
        <Modal.Footer>
          { footerMessage }
          { showSubmitButton ? (
            <Button
              bsStyle='primary'
              onClick={this.handleSubmit}
              disabled={ajaxInProgress}>
                {buttonCaption('Submit', ajaxInProgress)}
            </Button>
          ) : (
            <Button
              bsStyle='primary'
              onClick={this.handleCheck}
              disabled={hasInputErrors || ajaxInProgress}>
                {buttonCaption('Check', ajaxInProgress)}
            </Button>
          )}
          <Button onClick={this.close}>Cancel</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
