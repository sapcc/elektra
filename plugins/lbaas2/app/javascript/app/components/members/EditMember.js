import React, { useState, useEffect } from "react"
import { Modal, Button, DropdownButton } from "react-bootstrap"
import useCommons from "../../../lib/hooks/useCommons"
import { Form } from "lib/elektra-form"
import useMember from "../../../lib/hooks/useMember"
import ErrorPage from "../ErrorPage"
import { Table } from "react-bootstrap"
import NewMemberListItem from "./NewMemberListItem"
import usePool from "../../../lib/hooks/usePool"
import { addNotice } from "lib/flashes"
import Log from "../shared/logger"

const EditMember = (props) => {
  const {
    matchParams,
    searchParamsToString,
    formErrorMessage,
    fetchPoolsForSelect,
  } = useCommons()
  const { fetchMember, fetchMembers, updateMember } = useMember()
  const { persistPool } = usePool()
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)
  const [memberID, setMemberID] = useState(null)

  const [newMembers, setNewMembers] = useState([])

  const [members, setMembers] = useState({
    isLoading: false,
    error: null,
    items: [],
  })

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

  useEffect(() => {
    if (memberID) {
      loadMember()
    }
  }, [memberID])

  useEffect(() => {
    if (member.item) {
      loadMembers()
    }
  }, [member.item])

  const loadMember = () => {
    Log.debug("fetching member to edit")
    setMember({ ...member, isLoading: true, error: null })
    fetchMember(loadbalancerID, poolID, memberID)
      .then((data) => {
        setMember({
          ...member,
          isLoading: false,
          item: data.member,
          error: null,
        })
        setSelectedMember(data.member)
      })
      .catch((error) => {
        setMember({ ...member, isLoading: false, error: error })
      })
  }

  const loadMembers = () => {
    Log.debug("fetching members for table")
    setMembers({ ...members, isLoading: true })
    fetchMembers(loadbalancerID, poolID)
      .then((data) => {
        // set state saved so it can be edited
        const newItems = data.members || []
        for (let i = 0; i < newItems.length; i++) {
          newItems[i] = { ...newItems[i], ...{ saved: true } }
        }
        // remove teh member to edit from the list
        if (member.item) {
          const index = newItems.findIndex((item) => item.id == member.item.id)
          if (index >= 0) {
            newItems.splice(index, 1)
          }
        }

        setMembers({
          ...members,
          isLoading: false,
          items: newItems,
          error: null,
        })
      })
      .catch((error) => {
        setMembers({ ...members, isLoading: false, error: error })
      })
  }

  const setSelectedMember = (selectedMember) => {
    // create a unique id for the value
    // const newValues =  [{id: uniqueId("member_"), name: selectedMember.name, address: selectedMember.address}]
    selectedMember.edit = true
    setNewMembers([selectedMember])
  }

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
  const [initialValues, setInitialValues] = useState({})
  const [formErrors, setFormErrors] = useState(null)
  const [submitResults, setSubmitResults] = useState({})

  const validate = (values) => {
    return true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    return updateMember(loadbalancerID, poolID, memberID, values)
      .then((response) => {
        addNotice(
          <React.Fragment>
            Member <b>{response.data.name}</b> ({response.data.id}) is being
            created.
          </React.Fragment>
        )
        persistPool(loadbalancerID, poolID)
          .then(() => {})
          .catch((error) => {})
        close()
      })
      .catch((error) => {
        const results =
          error.response && error.response.data && error.response.data.results
        setFormErrors(formErrorMessage(error))
        if (results) {
          setSubmitResults(results)
        }
      })
  }

  const styles = {
    container: (base) => ({
      ...base,
      flex: 1,
    }),
  }

  const allMembers = [...newMembers, ...members.items]
  return (
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      backdrop="static"
      onExited={restoreUrl}
      aria-labelledby="contained-modal-title-lg"
      bsClass="lbaas2 modal"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">Edit Member</Modal.Title>
      </Modal.Header>

      {member.error ? (
        <Modal.Body>
          <ErrorPage
            headTitle="Edit Member"
            error={member.error}
            onReload={loadMember}
          />
        </Modal.Body>
      ) : (
        <React.Fragment>
          {member.isLoading ? (
            <Modal.Body>
              <span className="spinner" />
            </Modal.Body>
          ) : (
            <Form
              className="form"
              validate={validate}
              onSubmit={onSubmit}
              initialValues={initialValues}
              resetForm={false}
            >
              <Modal.Body>
                <p>
                  Members are servers that serve traffic behind a load balancer.
                  Each member is specified by the IP address and port that it
                  uses to serve traffic.
                </p>
                <Form.Errors errors={formErrors} />

                <div className="existing-members">
                  <b>Existing Members</b>
                  <div className="toolbar">
                    <div className="main-buttons">
                      <DropdownButton
                        disabled={true}
                        title="Add"
                        bsStyle="primary"
                        noCaret
                        pullRight
                        id="add-member-dropdown"
                      ></DropdownButton>
                    </div>
                  </div>

                  <Table className="table new_members" responsive>
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>
                          <abbr title="required">*</abbr>Name
                        </th>
                        <th>
                          <abbr title="required">*</abbr>Address
                        </th>
                        <th>
                          <abbr title="required">*</abbr>Protocol Port
                        </th>
                        <th style={{ width: "10%" }}>Weight</th>
                        <th style={{ width: "20%" }}>Tags</th>
                        <th></th>
                      </tr>
                    </thead>
                    <tbody>
                      {allMembers.length > 0 &&
                        allMembers.map((member, index) => (
                          <NewMemberListItem
                            member={member}
                            key={member.id}
                            index={index}
                            results={submitResults[member.id]}
                          />
                        ))}
                    </tbody>
                  </Table>
                  {members.isLoading ? (
                    <React.Fragment>
                      <span className="spinner" /> Loading Members...{" "}
                    </React.Fragment>
                  ) : (
                    ""
                  )}
                  {members.error ? (
                    <span className="text-danger">
                      {formErrorMessage(members.error)}
                    </span>
                  ) : (
                    ""
                  )}
                </div>
              </Modal.Body>
              <Modal.Footer>
                <Button onClick={close}>Cancel</Button>
                <Form.SubmitButton label="Save" />
              </Modal.Footer>
            </Form>
          )}
        </React.Fragment>
      )}
    </Modal>
  )
}

export default EditMember
