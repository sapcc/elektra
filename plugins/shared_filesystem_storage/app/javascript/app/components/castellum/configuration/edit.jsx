import { useContext } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';

//This needs to be a separate component because we can only access the
//Form.Context from inside the Form.
const FormBody = ({close, errors}) => {
  const values = useContext(Form.Context).formValues;

  let validationError = '';
  if (values.low_enabled == 'false' && values.high_enabled == 'false' && values.critical_enabled == 'false') {
    validationError = 'To use autoscaling, at least one threshold must be enabled.';
  }

  return (
    <React.Fragment>
      <Modal.Body>
        <Form.Errors errors={errors} />

        <Form.ElementHorizontal label='When usage is low:' name='low_enabled' labelWidth={5}>
          <Form.Input elementType='select'>
            <option value='false'>Do nothing</option>
            <option value='true'>Auto-shrink share</option>
          </Form.Input>
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Must observe low usage for (minutes):' name='low_delay' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='5' disabled={values.low_enabled == 'false'}/>
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Usage is low below (%):' name='low_usage' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='0' max='100' disabled={values.low_enabled == 'false'}/>
        </Form.ElementHorizontal>

        <Form.ElementHorizontal label='When usage is high:' name='high_enabled' labelWidth={5}>
          <Form.Input elementType='select'>
            <option value='false'>Do nothing</option>
            <option value='true'>Auto-extend share</option>
          </Form.Input>
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Must observe high usage for (minutes):' name='high_delay' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='5' disabled={values.high_enabled == 'false'}/>
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Usage is high above (%):' name='high_usage' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='0' max='100' disabled={values.high_enabled == 'false'}/>
        </Form.ElementHorizontal>

        <Form.ElementHorizontal label='When usage is critical:' name='critical_enabled' labelWidth={5}>
          <Form.Input elementType='select'>
            <option value='false'>Do nothing</option>
            <option value='true'>Auto-extend share immediately</option>
          </Form.Input>
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Usage is critical above (%):' name='critical_usage' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='0' max='100' disabled={values.critical_enabled == 'false'}/>
        </Form.ElementHorizontal>

        <Form.ElementHorizontal label='Each resize extends/shrinks by (%):' name='size_step' labelWidth={5} required>
          <Form.Input elementType='input' type='number' min='1' max='100' />
        </Form.ElementHorizontal>

        <Form.ElementHorizontal label='Never resize to less than (GiB):' name='size_minimum' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='0' />
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Never resize to more than (GiB):' name='size_maximum' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='0' />
        </Form.ElementHorizontal>
        <Form.ElementHorizontal label='Always leave this much free space (GiB):' name='free_minimum' labelWidth={5} labelClass='control-label secondary-label'>
          <Form.Input elementType='input' type='number' min='0' />
        </Form.ElementHorizontal>
      </Modal.Body>
      <Modal.Footer>
        <span className='not-valid-explanation'>{validationError}</span>
        <Form.SubmitButton label='Save'/>
        <Button onClick={close}>Cancel</Button>
      </Modal.Footer>
    </React.Fragment>
  );
};

export default class CastellumConfigurationEditModal extends React.Component {
  constructor(props) {
    super(props);
    this.state    = { show: true, initialValues: null, apiErrors: null };
    this.close    = this.close.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.validate = this.validate.bind(this);
  }

  componentDidMount() {
    this.initializeFormOnce(this.props);
  }
  componentWillReceiveProps(props) {
    this.initializeFormOnce(props);
  }
  initializeFormOnce(props) {
    if (this.state.initialValues) {
      return;
    }
    if (props.config.isFetching || props.config.receivedAt == null) {
      //wait until config was loaded
      return;
    }

    const cfg = props.config.data || {};
    const sec2min = seconds => Math.round(seconds / 60);
    this.setState({
      ...this.state,
      initialValues: {
        //'true' and 'false' are strings here because form values are stringly typed anyway
        low_enabled:              (cfg.low_threshold)      ? 'true' : 'false',
        low_usage:                (cfg.low_threshold      || {}).usage_percent || 50,
        low_delay:        sec2min((cfg.low_threshold      || {}).delay_seconds || 10800),
        high_enabled:             (cfg.high_threshold)     ? 'true' : 'false',
        high_usage:               (cfg.high_threshold     || {}).usage_percent || 80,
        high_delay:       sec2min((cfg.high_threshold     || {}).delay_seconds || 3600),
        critical_enabled:         (cfg.critical_threshold) ? 'true' : 'false',
        critical_usage:           (cfg.critical_threshold || {}).usage_percent || 95,
        size_step:                (cfg.size_steps         || {}).percent       || 10,
        size_minimum:             (cfg.size_constraints   || {}).minimum       || '',
        size_maximum:             (cfg.size_constraints   || {}).maximum       || '',
        free_minimum:             (cfg.size_constraints   || {}).minimum_free  || '',
      },
    });
  }

  close(e) {
    if (e) {
      e.stopPropagation();
    }
    this.setState({ ...this.state, show: false });
    setTimeout(() => this.props.history.replace('/autoscaling'), 300);
  }

  validate(values) {
    return (values.low_enabled == 'true' || values.high_enabled == 'true' || values.critical_enabled == 'true') && (values.size_step != '');
  }

  onSubmit(values) {
    //convert the flat `values` back into the JSON format expected by the Castellum API
    const config = {
      size_steps: {
        percent: parseInt(values.size_step, 10),
      },
    };
    if (values.low_enabled == 'true') {
      config.low_threshold = {
        usage_percent: parseInt(values.low_usage, 10),
        delay_seconds: parseInt(values.low_delay, 10) * 60,
      };
    }
    if (values.high_enabled == 'true') {
      config.high_threshold = {
        usage_percent: parseInt(values.high_usage, 10),
        delay_seconds: parseInt(values.high_delay, 10) * 60,
      };
    }
    if (values.critical_enabled == 'true') {
      config.critical_threshold = {
        usage_percent: parseInt(values.critical_usage, 10),
      };
    }
    if (values.size_minimum != '') {
      config.size_constraints = config.size_constraints || {};
      config.size_constraints.minimum = parseInt(values.size_minimum, 10);
    }
    if (values.size_maximum != '') {
      config.size_constraints = config.size_constraints || {};
      config.size_constraints.maximum = parseInt(values.size_maximum, 10);
    }
    if (values.free_minimum != '') {
      config.size_constraints = config.size_constraints || {};
      config.size_constraints.minimum_free = parseInt(values.free_minimum, 10);
    }

    this.props.configureAutoscaling(this.props.projectID, config)
      .then(this.close)
      .catch(e => this.setState({...this.state, apiErrors: e}));
  }

  render() {
    const config = this.props.config;
    if (config.isFetching || config.receivedAt == null) {
      //wait until config was loaded
      return null;
    }

    //NOTE: className on Modal ensures that plugin-specific CSS rules get applied
    return (
      <Modal backdrop='static' show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg" className='shared_filesystem_storage'>
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Configure Autoscaling</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={this.state.initialValues}>

          <FormBody close={this.close} errors={this.state.apiErrors} />
        </Form>
      </Modal>
    );
  }
}
