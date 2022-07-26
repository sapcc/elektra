import React from "react"
import PropTypes from "prop-types"
import makeCancelable from "lib/tools/cancelable_promise"
import { FormContext } from "./form_context"

// export default class Form extends React.Component {
//   static initialState = {
//     values: {},
//     isValid: false,
//     isSubmitting: false,
//     errors: null,
//   }

//   static defaultProps = {
//     initialValues: {},
//     resetForm: true,
//   }

//   static propTypes = {
//     initialValues: PropTypes.object,
//     validate: PropTypes.func.isRequired,
//     onSubmit: PropTypes.func.isRequired,
//     resetForm: PropTypes.bool,
//   }

//   constructor(props) {
//     super(props)
//     let initialValues = props.initialValues || {}

//     this.state = Object.assign({}, Form.initialState, {
//       values: initialValues,
//       isValid: props.validate ? props.validate(initialValues) : true,
//     })

//     this.onChange = this.onChange.bind(this)
//     this.resetForm = this.resetForm.bind(this)
//     this.updateValue = this.updateValue.bind(this)
//     this.onSubmit = this.onSubmit.bind(this)
//   }

//   UNSAFE_componentWillReceiveProps(nextProps) {
//     // set initialValues unless already set.
//     if (nextProps.initialValues && Object.keys(this.state.values).length == 0) {
//       this.setState({
//         values: nextProps.initialValues,
//         isValid: nextProps.validate
//           ? nextProps.validate(nextProps.initialValues)
//           : true,
//       })
//     }
//   }

//   componentWillUnmount() {
//     // cancel submit promis if already created
//     if (this.submitPromise) this.submitPromise.cancel()
//   }

//   resetForm() {
//     this.setState(Object.assign({}, Form.initialState))
//   }

//   updateValue(name, value) {
//     let values = { ...this.state.values }

//     if (typeof name === "object") {
//       values = Object.assign(values, name)
//     } else {
//       values[name] = value
//     }
//     let isValid = this.props.validate
//       ? this.props.validate(values)
//         ? true
//         : false
//       : true
//     this.setState(
//       { values, isValid },
//       this.props.onValueChange ? this.props.onValueChange(name, values) : null
//     )
//   }

//   onChange(e) {
//     e.preventDefault()
//     let name = e.target.name
//     let value = e.target.value
//     this.updateValue(name, value)
//   }

//   onSubmit(e) {
//     if (e) e.preventDefault()

//     this.setState({ isSubmitting: true })

//     this.submitPromise = makeCancelable(this.props.onSubmit(this.state.values))
//     this.submitPromise.promise
//       .then(() => {
//         // handle success
//         this.setState({ isSubmitting: false })
//         if (this.props.resetForm) this.resetForm()
//       })
//       .catch((reason) => {
//         if (!reason.isCanceled) {
//           // promise is not canceled
//           // handle errors
//           this.setState({ isSubmitting: false, errors: reason.errors })
//         }
//       })
//   }

//   render() {
//     let elementProps = { values: this.state.values }
//     const contextValue = {
//       formValues: this.state.values,
//       onChange: this.updateValue,
//       isFormSubmitting: this.state.isSubmitting,
//       isFormValid: this.state.isValid,
//       formErrors: this.state.errors,
//     }

//     return (
//       <form className={this.props.className} onSubmit={this.onSubmit}>
//         {this.state.isSubmitting}
//         <FormContext.Provider value={contextValue}>
//           {React.Children.map(this.props.children, (formElement) => {
//             if (!formElement) return null
//             return React.cloneElement(formElement, elementProps) // should be ok
//           })}
//         </FormContext.Provider>
//       </form>
//     )
//   }
// }

/*********************** NEW VERSION since 22.07.2022 **********************/
const Form = ({
  className,
  initialValues,
  resetForm,
  onSubmit,
  validate,
  onValueChange,
  children,
}) => {
  const [isValid, setIsValid] = React.useState(
    validate ? validate(initialValues) : true
  )
  const [errors, setErrors] = React.useState(null)
  const [isSubmitting, setIsSubmitting] = React.useState(false)
  const [values, setValues] = React.useState(initialValues)
  const submitPromise = React.useRef(null)

  React.useEffect(() => {
    setValues(initialValues)
  }, [setValues, initialValues])

  React.useEffect(
    () => () => {
      if (submitPromise.current) submitPromise.current.cancel()
    },
    []
  )

  const doResetForm = React.useCallback(() => {
    setIsValid(false)
    setIsSubmitting(false)
    setValues({})
    setErrors(null)
    setErrors(null)
  }, [setIsValid, setIsSubmitting, setValues])

  const updateValue = React.useCallback(
    (name, value) => {
      let newValues = { ...values }

      if (typeof name === "object") {
        newValues = Object.assign(newValues, name)
      } else {
        newValues[name] = value
      }
      let isValid = validate ? (validate(values) ? true : false) : true

      setValues(newValues)
      setIsValid(isValid)
      if (onValueChange) onValueChange(name, newValues)
    },
    [values, validate, onValueChange]
  )

  const handleSubmit = React.useCallback(
    (e) => {
      if (e) e.preventDefault()

      setIsSubmitting(true)

      submitPromise.current = makeCancelable(onSubmit(values))
      submitPromise.current.promise
        .then(() => {
          if (resetForm) doResetForm()
          setIsSubmitting(false)
        })
        .catch((reason) => {
          if (!reason.isCanceled) {
            // promise is not canceled
            // handle errors
            setErrors(reason.errors)
            setIsSubmitting(false)
          }
        })
    },
    [setIsSubmitting, values, onSubmit, doResetForm, setErrors, setIsSubmitting]
  )

  const contextValue = {
    formValues: values,
    onChange: updateValue,
    isFormSubmitting: isSubmitting,
    isFormValid: isValid,
    formErrors: errors,
  }

  let elementProps = { values }

  return (
    <form className={className} onSubmit={handleSubmit}>
      <FormContext.Provider value={contextValue}>
        {React.Children.map(children, (formElement) => {
          if (!formElement) return null
          return React.cloneElement(formElement, elementProps) // should be ok
        })}
      </FormContext.Provider>
    </form>
  )
}

Form.propTypes = {
  className: PropTypes.string,
  initialValues: PropTypes.object,
  resetForm: PropTypes.bool,
  onSubmit: PropTypes.func.isRequired,
  validate: PropTypes.func.isRequired,
  onValueChange: PropTypes.func,
  children: PropTypes.array,
}

Form.defaultProps = {
  initialValues: {},
  resetForm: true,
}

export default Form
