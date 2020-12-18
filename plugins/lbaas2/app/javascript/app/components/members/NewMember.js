import React, { useState, useEffect } from "react"
import { Modal, Button, DropdownButton, MenuItem } from "react-bootstrap"
import useCommons from "../../../lib/hooks/useCommons"
import { Form } from "lib/elektra-form"
import useMember from "../../../lib/hooks/useMember"
import Select from "react-select"
import uniqueId from "lodash/uniqueId"
import { addNotice } from "lib/flashes"
import { Table } from "react-bootstrap"
import NewMemberListItem from "./NewMemberListItem"
import usePool from "../../../lib/hooks/usePool"
import FormSubmitButton from "../shared/FormSubmitButton"
import Log from "../shared/logger"

const NewMember = (props) => {
  const { searchParamsToString, matchParams, formErrorMessage } = useCommons()
  const { fetchServers, createMember, fetchMembers } = useMember()
  const { persistPool } = usePool()
  const [servers, setServers] = useState({
    isLoading: false,
    error: null,
    items: [],
  })
  const [selectedServers, setSelectedServers] = useState([])
  const [members, setMembers] = useState({
    isLoading: false,
    error: null,
    items: [],
  })
  const [newMembers, setNewMembers] = useState([])

  useEffect(() => {
    Log.debug("fetching servers for select")
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const poolID = params.poolID
    // get servers for the select
    setServers({ ...servers, isLoading: true })
    fetchServers(lbID, poolID)
      .then((data) => {
        setServers({
          ...servers,
          isLoading: false,
          items: data.servers,
          error: null,
        })
      })
      .catch((error) => {
        setServers({ ...servers, isLoading: false, error: error })
      })
    // get the existing members
    setMembers({ ...members, isLoading: true })
    fetchMembers(lbID, poolID)
      .then((data) => {
        const newItems = data.members || []
        for (let i = 0; i < newItems.length; i++) {
          newItems[i] = { ...newItems[i], ...{ saved: true } }
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
  }, [])

  /**
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if (e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show) {
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
  const [showServerDropdown, setShowServerDropdown] = useState(false)

  const validate = (values) => {
    return newMembers && newMembers.length > 0
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // get the lb id and poolId
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const poolID = params.poolID

    //  filter items in context, which are removed from the list or already saved
    const filtered = Object.keys(values)
      .filter((key) => {
        let found = false
        for (let i = 0; i < newMembers.length; i++) {
          if (found) {
            break
          }
          // if found means the key from the form context exists in the selected member list
          // the context contains all references of members added and removed from the list
          // don't send rows already saved successfully
          if (!newMembers[i].saved) {
            found = key.includes(newMembers[i].id)
          }
        }
        return found
      })
      .reduce((obj, key) => {
        obj[key] = values[key]
        return obj
      }, {})

    // save the entered values in case of error
    setInitialValues(filtered)
    return createMember(lbID, poolID, filtered)
      .then((response) => {
        if (response && response.data) {
          addNotice(
            <React.Fragment>
              Member <b>{response.data.name}</b> ({response.data.id}) is being
              created.
            </React.Fragment>
          )
        }
        // TODO: fetch the Members and the pool again
        persistPool(lbID, poolID)
          .then(() => {})
          .catch((error) => {})
        close()
      })
      .catch((error) => {
        const results =
          error.response && error.response.data && error.response.data.results
        setFormErrors(formErrorMessage(error))
        if (results) {
          mergeSubmitResults(results)
          setSubmitResults(results)
        }
      })
  }

  const mergeSubmitResults = (results) => {
    let newItems = newMembers.slice() || []
    Object.keys(results).forEach((key) => {
      for (let i = 0; i < newItems.length; i++) {
        if (newItems[i].id == key) {
          if (results[key].saved) {
            newItems[i] = { ...newItems[i], ...results[key] }
          } else {
            newItems[i]["saved"] = results[key].saved
          }
          break
        }
      }
    })
    setNewMembers(newItems)
  }

  const addMembers = () => {
    // create a unique id for the value
    const newValues = [
      {
        id: uniqueId("member_"),
        name: selectedServers.name,
        address: selectedServers.address,
      },
    ]

    //  replace items
    setNewMembers(newValues)
    setSelectedServers([])
    setShowServerDropdown(false)
  }

  const addExternalMembers = () => {
    // replace values
    const newExtMembers = [{ id: uniqueId("member_"), type: "external" }]
    setNewMembers(newExtMembers)
  }

  const onShowServersDropdown = () => {
    setShowServerDropdown(true)
  }

  const onCancelShowServer = () => {
    setShowServerDropdown(false)
  }

  const onChangeServers = (values) => {
    setSelectedServers(values)
  }

  const onRemoveMember = (id) => {
    const index = newMembers.findIndex((item) => item.id == id)
    if (index < 0) {
      return
    }
    let newItems = newMembers.slice()
    newItems.splice(index, 1)
    setNewMembers(newItems)
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
        <Modal.Title id="contained-modal-title-lg">New Member</Modal.Title>
      </Modal.Header>

      <Form
        className="form"
        validate={validate}
        onSubmit={onSubmit}
        initialValues={initialValues}
        resetForm={false}
      >
        <Modal.Body>
          <p>
            Members are servers that serve traffic behind a load balancer. Each
            member is specified by the IP address and port that it uses to serve
            traffic.
          </p>
          <Form.Errors errors={formErrors} />

          <div className="existing-members">
            <b>Existing Members</b>
            <div className="toolbar toolbar-multi-line">
              {showServerDropdown && (
                <React.Fragment>
                  <div className="display-flex select-server-section">
                    <Select
                      className="basic-single server-select"
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
                    <Button
                      disabled={!selectedServers || selectedServers.length == 0}
                      bsStyle="primary"
                      className="margin-left"
                      onClick={addMembers}
                    >
                      Add
                    </Button>
                    <Button bsStyle="primary" onClick={onCancelShowServer}>
                      Cancel
                    </Button>
                  </div>
                  {servers.error ? (
                    <span className="text-danger">
                      {formErrorMessage(servers.error)}
                    </span>
                  ) : (
                    ""
                  )}
                </React.Fragment>
              )}

              <div className="main-buttons">
                {!showServerDropdown && (
                  <DropdownButton
                    disabled={members.isLoading}
                    title="Add"
                    bsStyle="primary"
                    noCaret
                    pullRight
                    id="add-member-dropdown"
                  >
                    <MenuItem onClick={onShowServersDropdown} eventKey="1">
                      By selecting a server
                    </MenuItem>
                    <MenuItem onClick={addExternalMembers} eventKey="2">
                      External
                    </MenuItem>
                  </DropdownButton>
                )}
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
                  <th>Weight</th>
                  <th>Backup Member</th>
                  <th>Tags</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {allMembers.length > 0 ? (
                  allMembers.map((member, index) => (
                    <NewMemberListItem
                      member={member}
                      key={member.id}
                      index={index}
                      onRemoveMember={onRemoveMember}
                      results={submitResults[member.id]}
                    />
                  ))
                ) : (
                  <tr>
                    <td colSpan="5">
                      {members.isLoading ? (
                        <span className="spinner" />
                      ) : (
                        "No Members added."
                      )}
                    </td>
                  </tr>
                )}
              </tbody>
            </Table>
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
          <FormSubmitButton
            label="Save"
            disabled={!newMembers || newMembers.length == 0}
          />
        </Modal.Footer>
      </Form>
    </Modal>
  )
}

export default NewMember
