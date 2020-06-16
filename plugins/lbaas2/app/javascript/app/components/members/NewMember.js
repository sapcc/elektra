import React, { useState,useEffect} from 'react';
import { Modal, Button } from 'react-bootstrap';
import useCommons from '../../../lib/hooks/useCommons'
import { Form } from 'lib/elektra-form';
import useMember from '../../../lib/hooks/useMember';
import Select from 'react-select';
import uniqueId from 'lodash/uniqueId'
import { addNotice } from 'lib/flashes';
import { Table } from 'react-bootstrap'
import NewMemberListItem from './NewMemberListItem'
import usePool from '../../../lib/hooks/usePool'

const NewMember = (props) => {
  const {searchParamsToString, matchParams, formErrorMessage} = useCommons()
  const {fetchServers,createMember, fetchMembers} = useMember()
  const {persistPool} = usePool()
  const [servers, setServers] = useState({
    isLoading: false,
    error: null,
    items: []
  })
  const [selectedServers, setSelectedServers] = useState([])
  const [members, setMembers] = useState({
    isLoading: false,
    error: null,
    items: []
  })
  const [newMembers,setNewMembers] = useState([])

  useEffect(() => {
    console.log('fetching servers for select')
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const poolID = params.poolID
    // get servers for the select
    setServers({...servers, isLoading:true})
    fetchServers(lbID,poolID).then((data) => {
      setServers({...servers, isLoading:false, items: data.servers, error: null})
    })
    .catch( (error) => {      
      setServers({...servers, isLoading:false, error: error})
    })
    // get the existing members
    setMembers({...members, isLoading:true})
    fetchMembers(lbID,poolID).then((data) => {
      const newItems = data.members || []
      for (let i = 0; i < newItems.length; i++) {
        newItems[i] = {...newItems[i], ...{saved: true}}
      }
      setMembers({...members, isLoading:false, items: newItems, error: null})
    })
    .catch( (error) => {      
      setMembers({...members, isLoading:false, error: error})
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
    return newMembers.length > 0
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // get the lb id and poolId
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const poolID = params.poolID

    //  filter items in context, which are removed from the list or already saved
    const filtered = Object.keys(values)
    .filter(key => {
      let found = false
      for (let i = 0; i < newMembers.length; i++) {
        if(found){break}
        // if found means the key from the form context exists in the selected member list
        // the context contains all references of members added and removed from the list
        // don't send rows already saved successfully
        if (!newMembers[i].saved) {
          found = key.includes(newMembers[i].id)
        }
      }
      return found
    }).reduce((obj, key) => {
      obj[key] = values[key];
      return obj;
    }, {});
    // save the entered values in case of error
    setInitialValues(filtered)
    return createMember(lbID, poolID, filtered).then((response) => {
      if(response && response.data) {
        addNotice(<React.Fragment>Member <b>{response.data.name}</b> ({response.data.id}) is being created.</React.Fragment>)
      }
      // TODO: fetch the Members and the pool again
      persistPool(lbID,poolID).then(() => {
      }).catch(error => {
      })
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
    let newItems = newMembers.slice() || []
    Object.keys(results).forEach( key => {
      for (let i = 0; i < newItems.length; i++) {
        if (newItems[i].id  == key) {          
          if (results[key].saved) {
            newItems[i] = {...newItems[i], ...results[key]}
          } else {
            newItems[i]['saved'] = results[key].saved
          }
          break
        }
      }
    })
    setNewMembers(newItems)
  }

  const addMembers = () => {
    // // create a unique id for the values
    // const newValues = (selectedServers || []).map((item, index) => {
    //   return {id: uniqueId("member_"), name: item.name, address: item.address}
    // })
    // // concat items
    // let newItems = (members.slice() || []).concat(newValues);
    // setMembers(newItems)
    
    // create a unique id for the value
    const newValues =  [{id: uniqueId("member_"), name: selectedServers.name, address: selectedServers.address}]

    //  replace items
    setNewMembers(newValues)
    setSelectedServers([])
  }

  const addExternalMembers = () => {
    // const newExtMembers = (members.slice() || []).concat({id: uniqueId("member_"), type: "external"});

    // replace values
    const newExtMembers = [{id: uniqueId("member_"), type: "external"}]
    setNewMembers(newExtMembers)
  }

  const onChangeServers = (values) => {
    setSelectedServers(values)
  }

  const onRemoveMember = (id) => {
    const index = newMembers.findIndex((item) => item.id==id);
    if (index<0) { return }
    let newItems = newMembers.slice()
    newItems.splice(index,1)
    setNewMembers(newItems)
  }

  const styles = {
    container: base => ({
      ...base,
      flex: 1
    })
  };

  const allMembers = [...newMembers,...members.items]
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
                isMulti={false}
                closeMenuOnSelect={true}
                styles={styles}
                value={selectedServers}
              />              
              <Button bsStyle="primary" disabled={members.isLoading} className="margin-left" onClick={addMembers}>Add</Button>  
            </div>
            { servers.error ? <span className="text-danger">{formErrorMessage(servers.error)}</span>:""}
          </Form.ElementInline>

          <div className='toolbar'>
            <div className="main-buttons">
              <Button bsStyle="primary" disabled={members.isLoading} onClick={addExternalMembers}>Add External</Button>  
            </div>
          </div>

          <Table className="table new_members" responsive>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Name</th>
                    <th><abbr title="required">*</abbr>Address</th>
                    <th><abbr title="required">*</abbr>Protocol Port</th>
                    <th style={{width:"10%"}}>Weight</th>
                    <th style={{width:"20%"}}>Tags</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
              {allMembers.length>0 ?
                allMembers.map( (member, index) =>
                  <NewMemberListItem member={member} key={member.id} index={index} onRemoveMember={onRemoveMember} results={submitResults[member.id]}/>
                )
              :
                <tr>
                  <td colSpan="5">
                  { members.isLoading ? <span className='spinner'/> : 'No Members added.' }
                  </td>
                </tr>
              }
            </tbody>
          </Table>
          { members.error ? <span className="text-danger">{formErrorMessage(members.error)}</span>:""}

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