import React, { useState, useEffect} from 'react';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import useCommons from '../../../lib/hooks/useCommons'
import useL7Policy from '../../../lib/hooks/useL7Policy'
import useListener from '../../../lib/hooks/useListener'
import SelectInput from '../shared/SelectInput'
import TagsInput from '../shared/TagsInput'
import { addNotice } from 'lib/flashes';

const NewL7Policy = (props) => {
  const {searchParamsToString, matchParams, formErrorMessage, fetchPoolsForSelect} = useCommons()
  const {createL7Policy} = useL7Policy()
  const {persistListener} = useListener()
  const [pools, setPools] = useState({
    isLoading: false,
    error: null,
    items: []
  })

  useEffect(() => {
    console.log('fetching pools')
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    // get pools for the select
    setPools({...pools, isLoading:true})
    fetchPoolsForSelect(lbID).then((data) => {
      setPools({...pools, isLoading:false, items: data.pools, error: null})
    })
    .catch( (error) => {      
      setPools({...pools, isLoading:false, error: error})
    })
  }, []);

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
  const [formErrors,setFormErrors] = useState(null)
  const [initialValues, setInitialValues] = useState({})
  const [actions, setActions] = useState([{value:"REDIRECT_PREFIX", label:"REDIRECT_PREFIX"}, {value: "REDIRECT_TO_POOL", label:"REDIRECT_TO_POOL"}, {value:"REDIRECT_TO_URL", label: "REDIRECT_TO_URL"}, {value: "REJECT", label: "REJECT"}])
  const [codes, setCodes] = useState([{value:"301", label:"301"}, {value:"302", label:"302"}, {value:"303", label:"303"}, {value:"307", label:"307"}, {value:"308", label:"308"}])
  const [showRedirectHttpCode, setShowRedirectHttpCode] = useState(false)
  const [showRedirectPoolID, setShowRedirectPoolID] = useState(false)
  const [showRedirectPrefix, setShowRedirectPrefix] = useState(false)
  const [showRedirectURL, setShowRedirectURL] = useState(false)

  const validate = ({name,description,position,action,redirect_url,redirect_prefix,redirect_http_code,redirect_pool_id,tags}) => {
    return name && action && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // save the entered values in case of error
    setInitialValues(values)
    // collect lb and listener id  
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const listenerID = params.listenerID
    return createL7Policy(lbID, listenerID, values).then((response) => {
      addNotice(<React.Fragment>L7 Policy <b>{response.data.name}</b> ({response.data.id}) is being created.</React.Fragment>)
      // load the listener again containing the new policy
      persistListener(lbID, listenerID).then(() => {
        close()
      }).catch(error => {
        console.log(JSON.stringify(error))
        // TODO update the listeners then
      })
    }).catch(error => {
      setFormErrors(formErrorMessage(error))
    })
  }

  const onSelectAction = (p) => {
    setShowRedirectHttpCode(false)
    setShowRedirectPoolID(false)
    setShowRedirectPrefix(false)
    setShowRedirectURL(false)
    switch (p.value) {
      case 'REDIRECT_PREFIX': {
        setShowRedirectHttpCode(true)
        setShowRedirectPrefix(true)
        break
      }
      case 'REDIRECT_TO_POOL': {
        setShowRedirectPoolID(true)
        break
      }
      case 'REDIRECT_TO_URL': {
        setShowRedirectHttpCode(true)
        setShowRedirectURL(true)
        break
      }
    }
  }

  const onSelectCode = () => {}
  const onSelectPoolChange = () => {}

  console.log("RENDER new L7 Policy")

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
          <Modal.Title id="contained-modal-title-lg">New L7 Policy</Modal.Title>
        </Modal.Header>


        <Form
          className='form form-horizontal'
          validate={validate}
          onSubmit={onSubmit}
          initialValues={initialValues}
          resetForm={false}>

          <Modal.Body>
            
            <p>Policies can be used to REJECT requests or REDIRECT traffic to specific pools or urls. The policy action will be executed when ALL L7 Rules are matched (Rules are combined with an AND). If you need an OR create another Policy with the same action and the needed rules.</p>
            <Form.Errors errors={formErrors}/>
            <Form.ElementHorizontal label='Name' name="name" required>
              <Form.Input elementType='input' type='text' name='name'/>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Description' name="description">
              <Form.Input elementType='input' type='text' name='description'/>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Position' name="position">
              <Form.Input elementType='input' type='text' name='position'/>
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                  Policies are evaluated in the order as defined by the 'position' attribute. The first one that matches a given request will be the one whose action is followed. If no policy matches a given request, then the request is routed to the listener's default pool (if it exists).
              </span>
            </Form.ElementHorizontal>
            <Form.ElementHorizontal label='Action' name="action" required>
            <SelectInput name="action" items={actions} onChange={onSelectAction} />
              <span className="help-block">
                <i className="fa fa-info-circle"></i>
                Will be executed when all L7 Rules are matched.
              </span>
            </Form.ElementHorizontal>

            {showRedirectHttpCode &&
              <Form.ElementHorizontal label='Redirect HTTP Code' name="redirect_http_code">
              <SelectInput name="redirect_http_code" items={codes} onChange={onSelectCode}/>
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  Requests matching this policy will be redirected to the specified URL or Prefix URL with the HTTP response code. Default is 302.
                </span>
              </Form.ElementHorizontal>
            }
            {showRedirectPoolID &&
              <Form.ElementHorizontal label='Redirect Pool ID' name="redirect_pool_id">
                <SelectInput name="redirect_pool_id" isLoading={pools.isLoading} items={pools.items} onChange={onSelectPoolChange} />
                { pools.error ? <span className="text-danger">{pools.error}</span>:""}
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  Requests matching this policy will be redirected to the pool with this ID.
                </span>
              </Form.ElementHorizontal>
            }
            {showRedirectPrefix &&
              <Form.ElementHorizontal label='Redirect Prefix' name="redirect_prefix">
                <Form.Input elementType='input' type='text' name='redirect_prefix'/>
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  Requests matching this policy will be redirected to this Prefix URL.
                </span>
              </Form.ElementHorizontal>
            }
            {showRedirectURL &&
              <Form.ElementHorizontal label='Redirect Url' name="redirect_url">
                <Form.Input elementType='input' type='text' name='redirect_url'/>
                <span className="help-block">
                  <i className="fa fa-info-circle"></i>
                  Requests matching this policy will be redirected to this URL.
                </span>
              </Form.ElementHorizontal>
            }

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
 
export default NewL7Policy;