import React, { useState, useEffect, useRef } from "react"
import { Modal, Button } from "react-bootstrap"
import useCommons from "../../../lib/hooks/useCommons"
import { Form } from "lib/elektra-form"
import useMember, { parseNestedValues } from "../../../lib/hooks/useMember"
import ErrorPage from "../ErrorPage"
import NewEditMemberListItem from "./NewEditMemberListItem"
import usePool from "../../../lib/hooks/usePool"
import { addNotice } from "lib/flashes"
import Log from "../shared/logger"
import ExistingMembersDropDown from "./ExistingMembersDropDown"
import EditMemberForm from "./EditMemberForm"
import { FormStateProvider } from "./FormState"
import SaveButton from "../shared/SaveButton"

const EditMember = (props) => {
  const { matchParams, searchParamsToString, formErrorMessage } = useCommons()
  const { fetchMember, updateMember } = useMember()
  const { persistPool } = usePool()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)
  const [memberID, setMemberID] = useState(null)
  const [member, setMember] = useState({
    isLoading: false,
    error: null,
    item: null,
  })

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const plID = params.poolID
    const mID = params.memberID
    setLoadbalancerID(lbID)
    setPoolID(plID)
    setMemberID(mID)
  }, [])

  // useEffect(() => {
  //   if (memberID) {
  //     loadMember()
  //   }
  // }, [memberID])

  // const loadMember = () => {
  //   Log.debug("fetching member to edit")
  //   setMember({ ...member, isLoading: true, error: null })
  //   fetchMember(loadbalancerID, poolID, memberID)
  //     .then((data) => {
  //       setMember({
  //         ...member,
  //         isLoading: false,
  //         item: data.member,
  //         error: null,
  //       })
  //     })
  //     .catch((error) => {
  //       setMember({ ...member, isLoading: false, error: error })
  //     })
  // }

  /*
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if (e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show) {
      // get the lb
      const params = matchParams(props)
      const lbID = params.loadbalancerID
      props.history.replace(
        `/loadbalancers/${lbID}/show?${searchParamsToString(props)}`
      )
    }
  }

  /**
   * Form stuff
   */

  // const onSubmit = (values) => {
  //   console.log("ONSUBMIT EDIT: ", values)

  //   // setFormErrors(null)
  //   // parse nested keys to objects
  //   // from values like member[XYZ][name]="arturo" to {XYZ:{name:"arturo"}}
  //   const newValues = parseNestedValues(values)
  //   return updateMember(loadbalancerID, poolID, memberID, newValues[memberID])
  //     .then((response) => {
  //       addNotice(
  //         <React.Fragment>
  //           Member <b>{response.data.name}</b> ({response.data.id}) is being
  //           updated.
  //         </React.Fragment>
  //       )
  //       // update pool
  //       persistPool(loadbalancerID, poolID)
  //       close()
  //     })
  //     .catch((error) => {
  //       setFormErrors(formErrorMessage(error))
  //     })
  // }

  const memberFormRef = useRef()
  const onSaveClicked = () => {
    memberFormRef.current.onSubmit()
  }

  const [formSubmitting, setFormSubmitting] = useState(false)
  const [isFormValid, setIsFormValid] = useState(false)
  const onFormCallback = ({ isSubmitting, isValid, shouldClose }) => {
    setFormSubmitting(isSubmitting || false)
    setIsFormValid(isValid || false)
    if (shouldClose) close()
  }

  // enforceFocus={false} needed so the clipboard.js library on bootstrap modals
  // https://github.com/zenorocha/clipboard.js/issues/388
  // https://github.com/twbs/bootstrap/issues/19971
  return (
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      backdrop="static"
      onExited={restoreUrl}
      aria-labelledby="contained-modal-title-lg"
      bsClass="lbaas2 modal"
      enforceFocus={false}
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Edit Member</Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <p>
          Members are servers that serve traffic behind a load balancer. Each
          member is specified by the IP address and port that it uses to serve
          traffic.
        </p>

        <FormStateProvider>
          <EditMemberForm
            loadbalancerID={loadbalancerID}
            poolID={poolID}
            memberID={memberID}
            onFormCallback={onFormCallback}
            ref={memberFormRef}
          />
        </FormStateProvider>

        <ExistingMembersDropDown props={props} poolID={poolID} />
      </Modal.Body>
      <Modal.Footer>
        <Button disabled={formSubmitting} onClick={close}>
          Cancel
        </Button>
        <SaveButton
          disabled={formSubmitting || !isFormValid}
          text={<>{formSubmitting && <span className="spinner" />}Save</>}
          tooltipText="Please check validation and required fields"
          callback={onSaveClicked}
        />
      </Modal.Footer>
    </Modal>
  )
}

export default EditMember
