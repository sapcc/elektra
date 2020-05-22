import React, { useState,useEffect} from 'react';
import { Modal, Button } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'
import { Form } from 'lib/elektra-form';
import useMember from '../../../lib/hooks/useMember';
import Select from 'react-select';
import NewMemberList from './NewMemberList'
import uniqueId from 'lodash/uniqueId'

const NewMember = (props) => {
  const {searchParamsToString, queryStringSearchValues, matchParams, formErrorMessage} = useCommons()
  const {fetchServers,createMembers} = useMember()
  const [servers, setServers] = useState({
    isLoading: false,
    error: null,
    items: []
  })
  const [selectedServers, setSelectedServers] = useState([])
  const [members,setMembers] = useState([])

  useEffect(() => {
    console.log('fetching servers for select')
    const qValues = queryStringSearchValues(props)
    const poolID = qValues.pool
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    // get servers for the select
    setServers({...servers, isLoading:true})
    fetchServers(lbID,poolID).then((data) => {
      setServers({...servers, isLoading:false, items: data.servers, error: null})
    })
    .catch( (error) => {      
      setServers({...servers, isLoading:false, error: error})
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
  const [initialValues, setInitialValues] = useState({})
  const [formErrors,setFormErrors] = useState(null)
  const [submitResults, setSubmitResults] = useState({})

  const validate = (values) => {
    return members.length > 0
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // get the lb id and poolId
    const qValues = queryStringSearchValues(props)
    const poolID = qValues.pool
    const params = matchParams(props)
    const lbID = params.loadbalancerID

    //  filter items in context, which are removed from the list or already saved
    const filtered = Object.keys(values)
    .filter(key => {
      let found = false
      for (let i = 0; i < members.length; i++) {
        if(found){break}
        // if found means the key from the form context exists in the selected member list
        // the context contains all references of members added and removed from the list
        // don't send rows already saved successfully
        if (!members[i].saved) {
          found = key.includes(members[i].id)
        }
      }
      return found
    }).reduce((obj, key) => {
      obj[key] = values[key];
      return obj;
    }, {});
    // save the entered values in case of error
    setInitialValues(filtered)

    return createMembers(lbID, poolID, filtered).then((response) => {
      if(response && response.data) {
       const savedItems = response.data || []
       savedItems.forEach( item => {
         console.log("item---->", item)
       })
      }
      // TODO: add notice
      // addNotice(<React.Fragment>Member <b>{response.data.name}</b> ({response.data.id}) is being created.</React.Fragment>)
      // TODO: fetch the Members and the pool again
      close()
    }).catch(error => {
      const results = error.response && error.response.data && error.response.data.results
      setFormErrors(formErrorMessage(error))
      if (results){
        mergeSubmitResults(results)
        setSubmitResults(results)
      }
    })
  }

  const mergeSubmitResults = (results) => {
    let newMembers = members.slice() || []
    Object.keys(results).forEach( key => {
      for (let i = 0; i < newMembers.length; i++) {
        if (newMembers[i].id  == key) {          
          if (results[key].saved) {
            newMembers[i] = {...newMembers[i], ...results[key]}
          } else {
            newMembers[i]['saved'] = results[key].saved
          }
          break
        }
      }
    })
    setMembers(newMembers)
  }

  const addMembers = () => {
    // create a unique id for the values
    const newValues = (selectedServers || []).map((item, index) => {
      return {id: uniqueId("member_"), name: item.name, address: item.address}
    })
    // concat items
    let newMembers = (members.slice() || []).concat(newValues);
    setMembers(newMembers)
    setSelectedServers([])
  }

  const addExternalMembers = () => {
    let newExtMembers = (members.slice() || []).concat({id: uniqueId("member_"), type: "external"});
    setMembers(newExtMembers)
  }

  const onChangeServers = (values) => {
    setSelectedServers(values)
  }

  const onRemoveMember = (id) => {
    const index = members.findIndex((item) => item.id==id);
    if (index<0) { return }
    let newItems = members.slice()
    newItems.splice(index,1)
    setMembers(newItems)
  }

  const styles = {
    container: base => ({
      ...base,
      flex: 1
    })
  };

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
        <Modal.Title id="contained-modal-title-lg">New Member</Modal.Title>
      </Modal.Header>

      <Form
          className='form'
          validate={validate}
          onSubmit={onSubmit}
          initialValues={initialValues}
          resetForm={false}>

        <Modal.Body>
          <p>Members are servers that serve traffic behind a load balancer. Each member is specified by the IP address and port that it uses to serve traffic.</p>
          <Form.Errors errors={formErrors}/>

          <Form.ElementInline label='Add a Member by selecting a Server' name="servers">
            <div className="display-flex">
              <Select
                className="basic-single"
                classNamePrefix="select"
                isDisabled={false}
                isLoading={servers.isLoading}
                isClearable={true}
                isRtl={false}
                isSearchable={true}
                name="servers"
                onChange={onChangeServers}
                options={servers.items}
                isMulti={true}
                closeMenuOnSelect={false}
                styles={styles}
                value={selectedServers}
              />              
              <Button bsStyle="primary" className="margin-left" onClick={addMembers}>Add</Button>  
            </div>
            { servers.error ? <span className="text-danger">{formErrorMessage(servers.error)}</span>:""}
          </Form.ElementInline>

          <div className='toolbar'>
            <div className="main-buttons">
              <Button bsStyle="primary" onClick={addExternalMembers}>Add External</Button>  
            </div>
          </div>
          <NewMemberList members={members} onRemoveMember={onRemoveMember} results={submitResults}/>
        </Modal.Body>
        <Modal.Footer>  
          <Button onClick={close}>Cancel</Button>
          <Form.SubmitButton label='Save'/>
        </Modal.Footer>
      </Form>
    </Modal>
   );
}
 
export default NewMember;