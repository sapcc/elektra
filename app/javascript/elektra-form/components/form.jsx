import PropTypes from 'prop-types';

export const Form = ({validate,handleSubmit}) => (WrappedComponent) =>
  class FormWrapper extends React.Component {
    static initialState = {
      values: {},
      isValid: false,
      isSubmitting: false,
      errors: null
    }

    constructor(props, context) {
      super(props, context);
      this.state = Object.assign({},FormWrapper.initialState)
      this.onChange = this.onChange.bind(this);
      this.resetForm = this.resetForm.bind(this);
      this.updateValue = this.updateValue.bind(this);
      this.setIsSubmitting = this.setIsSubmitting.bind(this);
      this.setIsValid = this.setIsValid.bind(this);
      this.onSubmit = this.onSubmit.bind(this);
    }

    static childContextTypes = {
      formValues: PropTypes.object,
      onChange: PropTypes.func,
      isFormSubmitting: PropTypes.bool,
      isFormValid: PropTypes.bool,
      formErrors: PropTypes.oneOfType([PropTypes.string, PropTypes.object, PropTypes.array])
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

    resetForm(){
      this.setState(Object.assign({},FormWrapper.initialState))
    }

    updateValue(name,value) {
      let values = Object.assign({},this.state.values)
      values[name] = value
      let isValid = validate(values) ? true : false
      this.setState({ values, isValid })
    }

    onChange(e) {
      e.preventDefault();
      let name = e.target.name
      let value = e.target.value
      this.updateValue(name,value)
    }

    setIsValid(isValid) {
      this.setState({isValid})
    }

    setIsSubmitting(isSubmitting) {
      this.setState({isSubmitting})
    }

    onSubmit(e, {onSuccess,onErrors}) {
      e.preventDefault()
      this.setIsSubmitting(true)
      this.props.handleSubmit(this.state.values, {
        handleSuccess: () => {
          this.setIsSubmitting(false)
          this.resetForm()
          if(this.props.onHide) this.props.onHide()
        },
        handleErrors: (errors) => {
          this.setIsSubmitting(false)
          this.setState({errors})
        }
      })
    }

    render() {
      let elementProps = {
        values: this.state.values,
        onChange: this.onChange,
        isValid: this.state.isValid,
        isSubmitting: this.state.isSubmitting,
        resetForm: this.resetForm,
        onSubmit: this.onSubmit,
        ...this.props
      }
      return (
        <WrappedComponent {...elementProps} />
      )
    }
  }
