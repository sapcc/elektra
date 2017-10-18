import PropTypes from 'prop-types';
import { Modal, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { Form } from 'elektra-form';

import axios from 'axios';

const protocols = ['NFS','CIFS']



// class FormProvider extends React.Component {
//   static initialState = {
//     values: {},
//     isValid: false,
//     errors: null
//   }
//
//   constructor(props, context) {
//     super(props, context);
//     this.state = Object.assign({},FormProvider.initialState)
//     this.onChange = this.onChange.bind(this);
//     this.resetForm = this.resetForm.bind(this);
//     this.updateValue = this.updateValue.bind(this);
//     this.validate = this.validate.bind(this);
//     this.onSubmit = this.onSubmit.bind(this);
//   }
//
//   static childContextTypes = {
//     formValues: PropTypes.object,
//     onChange: PropTypes.func,
//     isFormSubmitting: PropTypes.bool,
//     isFormValid: PropTypes.bool,
//     formErrors: PropTypes.object
//   };
//
//   getChildContext() {
//     return {
//       formValues: this.state.values,
//       onChange: this.updateValue,
//       isFormSubmitting: this.state.isSubmitting,
//       isFormValid: this.state.isValid,
//       formErrors: this.state.errors
//     };
//   }
//
//   resetForm(){
//     this.setState(Object.assign({},FormProvider.initialState))
//   }
//
//   validate(values) {
//     if (!this.props.validate) return true;
//     return this.props.validate(values) ? true : false
//   }
//
//   updateValue(name,value) {
//     let values = Object.assign({},this.state.values)
//     let isValid = this.validate(values)
//     values[name] = value
//     this.setState({ values, isValid })
//   }
//
//   onChange(e) {
//     e.preventDefault();
//     let name = e.target.name
//     let value = e.target.value
//     this.updateValue(name,value)
//   }
//
//   onSubmit(e) {
//     e.preventDefault()
//     this.setState({isSubmitting: true})
//     axios({
//       method:this.props.method,
//       url: this.props.action,
//       responseType:'json'
//     }).then( (response) => {
//       this.props.onSubmitSuccess(response.data)
//       this.setState({isSubmitting: false})
//     }).catch( (error) => {
//       this.setState({errors: error})
//       this.setState({isSubmitting: false})
//     })
//   }
//
//   render() {
//     return (
//       <form onSubmit={this.onSubmit}>{this.props.children}</form>
//     )
//   }
// }
//
// export default ({onHide,show}) => {
//   let validate = (values) => {
//     return values.name && true
//   }
//
//   let onSubmitSuccess = (values) => {
//     console.log('onSubmitSuccess',values)
//   }
//
//   return (
//     <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
//       <Modal.Header closeButton>
//         <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
//       </Modal.Header>
//
//       <FormProvider onSubmitSuccess={onSubmitSuccess} validate={validate} action='shares' method='post'>
//         <Modal.Body>
//           <Form.FormErrors/>
//           <Form.FormInput elementType='input' name='name'/>
//         </Modal.Body>
//         <Modal.Footer>
//           <Button onClick={onHide}>Cancel</Button>
//           <Form.SubmitButton label='Save'/>
//         </Modal.Footer>
//       </FormProvider>
//     </Modal>
//   )
// }


// export default ({show,onHide,onChange,values={},isValid}) => {
//
//   return (
//     <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
//       <Modal.Header closeButton>
//         <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
//       </Modal.Header>
//
//       <FormProvider>
//         <Modal.Body>
//           <Form.FormErrors/>
//           <input name="test" value={values.test || ''} onChange={onChange}/>
//           <br/>
//           <Form.FormInput elementType='input' name='check'/>
//           <br/>
//           { Object.keys(values).map((key) => <span key={key}>{key} => {values[key]}</span>)}
//           <br/>
//           <span>is valid {`${isValid}`}</span>
//         </Modal.Body>
//         <Modal.Footer>
//           <Button onClick={onHide}>Cancel</Button>
//           <Form.SubmitButton label='Save'/>
//         </Modal.Footer>
//       </FormProvider>
//     </Modal>
//   )
// }

const FormX = ({validate,handleSubmit}) => (WrappedComponent) =>
  class FormProvider extends React.Component {
    static initialState = {
      isValid: false,
      errors: null
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

    resetForm(){
      this.setState(Object.assign({},FormProvider.initialState))
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

let NewShareForm = ({onHide,show, values, onSubmit}) => {
  return (
    <Modal show={show} onHide={onHide} bsSize="large" aria-labelledby="contained-modal-title-lg">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
      </Modal.Header>

      <form onSubmit={(e) => onSubmit(e, {onSuccess: onHide}) }>
        <Modal.Body>
          <Form.FormErrors/>

        <Form.FormElement label='Name' name='name'>
          <Form.FormInput elementType='input' name='name'/>
        </Form.FormElement>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={onHide}>Cancel</Button>
          <Form.SubmitButton label='Save'/>
        </Modal.Footer>
      </form>
    </Modal>
  )
}

export default FormX({
  intialValues: {},
  validate: (values) => (values.name && true),
  handleSubmit: (values, {handleSuccess,handleErrors}) => this.props.handleSuccess
})(NewShareForm)
