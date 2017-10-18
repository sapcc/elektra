import PropTypes from 'prop-types';

export const Form = (WrappedComponent) =>
  class FormWrapper extends React.Component {
    static initialState = {
      values: {},
      isValid: false,
      errors: null
    }

    constructor(props, context) {
      super(props, context);
      this.state = Object.assign({},FormWrapper.initialState)
      this.updateValue = this.updateValue.bind(this);
      this.onChange = this.onChange.bind(this);
      this.setIsSubmitting = this.setIsSubmitting.bind(this);
      this.setIsValid = this.setIsValid.bind(this);
      this.resetForm = this.resetForm.bind(this);
    }

    static childContextTypes = {
      formValues: PropTypes.object,
      onChange: PropTypes.func,
      isFormSubmitting: PropTypes.bool,
      isFormValid: PropTypes.bool,
      formErrors: PropTypes.object
    };

    getChildContext() {
      return {
        formValues: this.state.values,
        onChange: this.updateValue,
        isFormSubmitting: this.state.isSubmitting,
        isFormValid: this.state.isValid,
        formErrors: this.state.errors
      };
    }

    validate(values) {
      return values.test ? true : false
    }

    resetForm(){
      this.setState(Object.assign({},FormWrapper.initialState))
    }

    updateValue(name,value) {
      let values = Object.assign({},this.state.values)
      values[name] = value
      let isValid = this.validate(values)
      this.setState({ values, isValid })
    }

    onChange(e) {
      e.preventDefault();
      let name = e.target.name
      let value = e.target.value
      this.updateValue(name,value)
    }

    setIsSubmitting(isSubmitting) {
      this.setState({isSubmitting})
    }

    setIsValid(isValid) {
      this.setState({isValid})
    }

    render() {
      let elementProps = {
        values: this.state.values,
        setIsSubmitting: this.setIsSubmitting,
        setIsValid: this.setIsValid,
        onChange: this.onChange,
        isValid: this.state.isValid,
        isSubmitting: this.state.isSubmitting,
        resetForm: this.resetForm,
        ...this.props
      }
      return (
        <WrappedComponent {...elementProps} />
      )
    }
  }
