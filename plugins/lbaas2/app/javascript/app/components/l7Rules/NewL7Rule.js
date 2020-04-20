import React, { useState} from 'react';
import useCommons from '../../../lib/hooks/useCommons'
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import HelpPopover from '../shared/HelpPopover'
import SelectInput from '../shared/SelectInput'
import useL7Rule from '../../../lib/hooks/useL7Rule';
import TagsInput from '../shared/TagsInput'
import useL7Policy from '../../../lib/hooks/useL7Policy'
import { addNotice } from 'lib/flashes';

const NewL7Rule = (props) => {
  const {searchParamsToString, queryStringSearchValues, matchParams, formErrorMessage} = useCommons()
  const {ruleTypes, ruleCompareType, createL7Rule} = useL7Rule()
  const {persistL7Policy} = useL7Policy()

  /**
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if(e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show){
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(`/loadbalancers/${lbID}/show?${searchParamsToString(props)}`)
    }
  }

  /**
   * Form stuff
   */
  const [initialValues, setInitialValues] = useState({})
  const [formErrors,setFormErrors] = useState(null)

  const validate = ({type,compare_type,value,key,invert,tags}) => {
    return type && compare_type && value && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // save the entered values in case of error
    setInitialValues(values)
    // collect lb and listener id
    const qValues = queryStringSearchValues(props)
    const listenerID = qValues.listener
    const l7policyID = qValues.l7policy
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    return createL7Rule(lbID, listenerID, l7policyID, values).then((response) => {
      addNotice(<React.Fragment>L7 Rule <b>{response.data.type}</b> ({response.data.id}) is being created.</React.Fragment>)
      // fetch the policy again containing the new l7rule
      persistL7Policy(lbID, listenerID, l7policyID).then(() => {
      }).catch(error => {
      })
      close()
    }).catch(error => {
      setFormErrors(formErrorMessage(error))
    })
  }

  const onSelectType = () => {}
  const onSelectCompareType = () => {}

  const helpBlockTextType = () => {
    return (
      <ul className="help-block-popover-scroll">
        {ruleTypes().map( (t, index) =>
          <li key={index}>{t.label}: {t.description}</li>
        )}
      </ul>
    )
  }

  const helpBlockTextCompareType = () => {
    return (
      <ul className="help-block-popover-scroll">
        {ruleCompareType().map( (t, index) =>
          <li key={index}>{t.label}: {t.description}</li>
        )}
      </ul>
    )
  }

  return ( 
    <Modal
    show={show}
    onHide={close}
    bsSize="large"
    backdrop='static'
    onExited={restoreUrl}
    aria-labelledby="contained-modal-title-lg"
    bsClass="lbaas2 modal">
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">New L7 Rule</Modal.Title>
      </Modal.Header>

      <Form
          className='form form-horizontal'
          validate={validate}
          onSubmit={onSubmit}
          initialValues={initialValues}
          resetForm={false}>

        <Modal.Body>
          <p>Layer 7 rules are individual statements of logic which match parts of an HTTP request, session, or other protocol-specific data for any given client request. All the layer 7 rules associated with a given layer 7 policy are logically ANDed together to see whether the policy matches a given client request.</p>
          <Form.Errors errors={formErrors}/>
          <Form.ElementHorizontal label='Type' name="type" required>
            <SelectInput name="type" items={ruleTypes()} onChange={onSelectType} />
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              <span className="help-block-text">The L7 rule type. See help for more information.</span>
              <HelpPopover text={helpBlockTextType()} />
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Compare Type' name="compare_type" required>
            <SelectInput name="compare_type" items={ruleCompareType()} onChange={onSelectCompareType} />
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              <span className="help-block-text">The L7 rule compare type. See help for more information.</span>
              <HelpPopover text={helpBlockTextCompareType()} />
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Inverse Comparisation (NOT)' name="invert">
            <Form.Input elementType='input' type='checkbox' name='invert'/>
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              When true the logic of the rule is inverted. For example, with invert true, equal to would become not equal to. Default is false.
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Key' name="key">
            <Form.Input elementType='input' type='text' name='key'/>
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              The key to use for the comparison. For example, the name of the cookie to evaluate.
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Value' name="value" required>
            <Form.Input elementType='input' type='text' name='value'/>
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              The value to use for the comparison. For example, the file type to compare.
            </span>
          </Form.ElementHorizontal>
          <Form.ElementHorizontal label='Tags' name="tags">
            <TagsInput name="tags" />
            <span className="help-block">
              <i className="fa fa-info-circle"></i>
              Start a new tag typing a string and hitting the Enter or Tab key.
            </span>
          </Form.ElementHorizontal>  
        </Modal.Body>
        <Modal.Footer>  
            <Button onClick={close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>
      </Form>

    </Modal>
   );
}
 
export default NewL7Rule;