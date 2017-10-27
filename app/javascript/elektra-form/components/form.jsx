import PropTypes from 'prop-types';

export default class Form extends React.Component {
  static initialState = {
    values: {},
    isValid: false,
    isSubmitting: false,
    errors: null
  }

  static defaultProps = {
    initialValues: {},
    resetForm: true
  }

  static propTypes = {
    initialValues: PropTypes.object,
    validate: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    resetForm: PropTypes.bool
  }

  constructor(props, context) {
    super(props, context);
    this.state = Object.assign({},Form.initialState,{
      values: props.initialValues || {}
    })

    this.onChange = this.onChange.bind(this);
    this.resetForm = this.resetForm.bind(this);
    this.updateValue = this.updateValue.bind(this);


    this.onSubmit = this.onSubmit.bind(this);
    this.handleSuccess = this.handleSuccess.bind(this);
    this.handleErrors = this.handleErrors.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    // set initialValues unless already set.
    if( nextProps.initialValues && Object.keys(this.state.values).length==0) {
      this.setState({values: nextProps.initialValues})
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
    this.setState(Object.assign({},Form.initialState))
  }

  updateValue(name,value) {
    let values = Object.assign({},this.state.values)
    values[name] = value
    let isValid = this.props.validate ? (this.props.validate(values) ? true : false) : true

    this.setState({ values, isValid }, this.props.onValueChange ? this.props.onValueChange(name, values) : null)
  }

  onChange(e) {
    e.preventDefault();
    let name = e.target.name
    let value = e.target.value
    this.updateValue(name,value)
  }

  handleSuccess() {
    this.setState({isSubmitting: false})
    if(this.props.resetForm) this.resetForm()
  }

  handleErrors(errors) {
    this.setState({isSubmitting: false})
    this.setState({errors})
  }

  onSubmit(e){
    e.preventDefault()
    this.setState({isSubmitting: true})
    if(this.props.onSubmit)
      this.props.onSubmit(this.state.values, {
        handleSuccess: this.handleSuccess,
        handleErrors: this.handleErrors
      })
  }

  render() {
    let elementProps = {values: this.state.values}
    return (
      <form className={this.props.className} onSubmit={this.onSubmit}>
        { React.Children.map(this.props.children, (formElement) =>
          React.cloneElement(formElement,elementProps) // should be ok
        )}
      </form>
    )
  }
}
