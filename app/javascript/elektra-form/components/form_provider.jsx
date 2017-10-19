import PropTypes from 'prop-types';

// export const Form = (WrappedComponent) =>
//   class FormWrapper extends React.Component {
//     static initialState = {
//       values: {},
//       isValid: false,
//       isSubmitting: false,
//       errors: null
//     }
//
//     static propTypes = {
//       initialValues: PropTypes.object,
//       validate: PropTypes.func.isRequired,
//       handleSubmit: PropTypes.func.isRequired
//     }
//
//     constructor(props, context) {
//       console.log('FormWrapper did created')
//       super(props, context);
//       this.state = Object.assign({},FormWrapper.initialState)
//       this.onChange = this.onChange.bind(this);
//       this.resetForm = this.resetForm.bind(this);
//       this.updateValue = this.updateValue.bind(this);
//       this.setIsSubmitting = this.setIsSubmitting.bind(this);
//       this.setIsValid = this.setIsValid.bind(this);
//       this.onSubmit = this.onSubmit.bind(this);
//     }
//
//     componentWillReceiveProps(nextProps) {
//       if( nextProps.initialValues &&
//         (!this.state.values || Object.keys(this.state.values).length === 0)) {
//         this.setState({values: nextProps.initialValues}, () => console.log(this.state))
//       }
//       console.log('nextProps',nextProps)
//     }
//
//     static childContextTypes = {
//       formValues: PropTypes.object,
//       onChange: PropTypes.func,
//       isFormSubmitting: PropTypes.bool,
//       isFormValid: PropTypes.bool,
//       formErrors: PropTypes.oneOfType([PropTypes.string, PropTypes.object, PropTypes.array])
//     };
//
//     getChildContext() {
//       return {
//         formValues: this.state.values,
//         onChange: this.updateValue,
//         isFormSubmitting: this.state.isSubmitting,
//         isFormValid: this.state.isValid,
//         formErrors: this.state.errors
//       };
//     }
//
//     resetForm(){
//       this.setState(Object.assign({},FormWrapper.initialState,{
//         values: this.props.initialValues || {}
//       }))
//     }
//
//     updateValue(name,value) {
//       let values = Object.assign({},this.state.values)
//       values[name] = value
//       let isValid = this.props.validate(values) ? true : false
//       this.setState({ values, isValid })
//     }
//
//     onChange(e) {
//       e.preventDefault();
//       let name = e.target.name
//       let value = e.target.value
//       this.updateValue(name,value)
//     }
//
//     setIsValid(isValid) {
//       this.setState({isValid})
//     }
//
//     setIsSubmitting(isSubmitting) {
//       this.setState({isSubmitting})
//     }
//
//     onSubmit(e, {onSuccess,onErrors}) {
//       e.preventDefault()
//       this.setIsSubmitting(true)
//       this.props.handleSubmit(this.state.values, {
//         handleSuccess: () => {
//           this.setIsSubmitting(false)
//           this.resetForm()
//           if(this.props.onHide) this.props.onHide()
//         },
//         handleErrors: (errors) => {
//           this.setIsSubmitting(false)
//           this.setState({errors})
//         }
//       })
//     }
//
//     render() {
//       let elementProps = {
//         values: this.state.values,
//         onChange: this.onChange,
//         isValid: this.state.isValid,
//         isSubmitting: this.state.isSubmitting,
//         resetForm: this.resetForm,
//         onSubmit: this.onSubmit,
//         ...this.props
//       }
//       return (
//         <WrappedComponent {...elementProps} />
//       )
//     }
//   }

export class FormProvider extends React.Component {
  static initialState = {
    values: {},
    isValid: false,
    isSubmitting: false,
    errors: null
  }

  static propTypes = {
    initialValues: PropTypes.object,
    validate: PropTypes.func.isRequired,
    handleSubmit: PropTypes.func.isRequired
  }

  constructor(props, context) {
    super(props, context);
    this.state = Object.assign({},FormProvider.initialState)
    this.onChange = this.onChange.bind(this);
    this.resetForm = this.resetForm.bind(this);
    this.updateValue = this.updateValue.bind(this);
    this.setIsSubmitting = this.setIsSubmitting.bind(this);
    this.setIsValid = this.setIsValid.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    if( nextProps.initialValues &&
      (!this.state.values || Object.keys(this.state.values).length === 0)) {
      this.setState({values: nextProps.initialValues}, () => console.log(this.state))
    }
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
    this.setState(Object.assign({},FormProvider.initialState,{
      values: this.props.initialValues || {}
    }))
  }

  updateValue(name,value) {
    let values = Object.assign({},this.state.values)
    values[name] = value
    let isValid = this.props.validate(values) ? true : false
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
      <div>
        { React.Children.map(this.props.children, (form) =>
          React.cloneElement(form,elementProps) // should be ok
        )}
      </div>
    )
  }
}
