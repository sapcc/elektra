import React, { useState, useEffect, useRef } from "react"
import { Modal, Button } from "react-bootstrap"
import useCommons from "../../../lib/hooks/useCommons"
import useMember, { filterItems } from "../../../lib/hooks/useMember"
import usePool from "../../../lib/hooks/usePool"
import Log from "../shared/logger"
import { SearchField } from "lib/components/search_field"
import MembersTable from "./MembersTable"
import { FormStateProvider } from "./FormState"
import MemberForm from "./MemberForm"
import SaveButton from "../shared/SaveButton"

const NewMember = (props) => {
  const { searchParamsToString, matchParams, formErrorMessage, errorMessage } =
    useCommons()
  const { fetchServers, create, fetchMembers, persistMembers } = useMember()
  const { persistPool } = usePool()
  const [servers, setServers] = useState({
    isLoading: false,
    error: null,
    items: [],
  })
  const [members, setMembers] = useState({
    isLoading: false,
    error: null,
    items: [],
  })
  const [loadbalancerID, setLoadbalancerID] = useState(null)
  const [poolID, setPoolID] = useState(null)
  const [showExistingMembers, setShowExistingMembers] = useState(false)
  const [searchTerm, setSearchTerm] = useState(null)
  const [filteredItems, setFilteredItems] = useState([])
  const [show, setShow] = useState(true)

  useEffect(() => {
    // get the lb
    const params = matchParams(props)
    const lbID = params.loadbalancerID
    const plID = params.poolID
    setLoadbalancerID(lbID)
    setPoolID(plID)
  }, [])

  useEffect(() => {
    if (!loadbalancerID && !poolID) return
    Log.debug("fetching servers for select")
    // get servers for the select
    setServers({ ...servers, isLoading: true })
    fetchServers(loadbalancerID, poolID)
      .then((data) => {
        setServers({
          ...servers,
          isLoading: false,
          items: data.servers,
          error: null,
        })
      })
      .catch((error) => {
        setServers({
          ...servers,
          isLoading: false,
          error: errorMessage(error),
        })
      })
    // get the existing members
    setMembers({ ...members, isLoading: true })
    fetchMembers(loadbalancerID, poolID)
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
  }, [loadbalancerID, poolID])

  useEffect(() => {
    const newItems = filterItems(searchTerm, members.items)
    setFilteredItems(newItems)
  }, [searchTerm, members])

  const close = (e) => {
    if (e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show) {
      props.history.replace(
        `/loadbalancers/${loadbalancerID}/show?${searchParamsToString(props)}`
      )
    }
  }

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

  // enforceFocus={false} needed so the clipboard.js library works on bootstrap modals
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
        <Modal.Title id="contained-modal-title-lg">New Member</Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <p>
          Members are servers that serve traffic behind a load balancer. Each
          member is specified by the IP address and port that it uses to serve
          traffic.
        </p>

        <FormStateProvider>
          <MemberForm
            loadbalancerID={loadbalancerID}
            poolID={poolID}
            servers={servers}
            onFormCallback={onFormCallback}
            ref={memberFormRef}
          />
        </FormStateProvider>

        <div className="existing-members">
          <div className="display-flex">
            <div
              className="action-link"
              onClick={() => setShowExistingMembers(!showExistingMembers)}
              data-toggle="collapse"
              data-target="#collapseExistingMembers"
              aria-expanded={showExistingMembers}
              aria-controls="collapseExistingMembers"
            >
              {showExistingMembers ? (
                <>
                  <span>Hide existing members</span>
                  <i className="fa fa-chevron-circle-up" />
                </>
              ) : (
                <>
                  <span>Show existing members</span>
                  <i className="fa fa-chevron-circle-down" />
                </>
              )}
            </div>
          </div>

          <div className="collapse" id="collapseExistingMembers">
            <div className="toolbar searchToolbar">
              <SearchField
                value={searchTerm}
                onChange={(term) => setSearchTerm(term)}
                placeholder="Name, ID, IP or port"
                text="Searches by Name, ID, IP address or protocol port."
              />
            </div>

            <MembersTable
              members={filteredItems}
              props={props}
              poolID={poolID}
              searchTerm={searchTerm}
              isLoading={members.isLoading}
            />
            {members.error ? (
              <span className="text-danger">
                {formErrorMessage(members.error)}
              </span>
            ) : (
              ""
            )}
          </div>
        </div>
      </Modal.Body>
      <Modal.Footer>
        <Button disabled={formSubmitting} onClick={close}>
          Cancel
        </Button>
        {/* <Button
          bsStyle="primary"
          disabled={formSubmitting || !isFormValid}
          onClick={onSaveClicked}
        >
          {formSubmitting && <span className="spinner"></span>}
          save
        </Button> */}
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

export default NewMember
