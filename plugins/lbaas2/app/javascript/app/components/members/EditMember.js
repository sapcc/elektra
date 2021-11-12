import React, { useState, useEffect } from "react";
import { Modal, Button } from "react-bootstrap";
import useCommons from "../../../lib/hooks/useCommons";
import { Form } from "lib/elektra-form";
import useMember, {
  filterItems,
  parseNestedValues,
} from "../../../lib/hooks/useMember";
import ErrorPage from "../ErrorPage";
import NewEditMemberListItem from "./NewEditMemberListItem";
import usePool from "../../../lib/hooks/usePool";
import { addNotice } from "lib/flashes";
import Log from "../shared/logger";
import MembersTable from "./MembersTable";
import { SearchField } from "lib/components/search_field";

const EditMember = (props) => {
  const { matchParams, searchParamsToString, formErrorMessage } = useCommons();
  const { fetchMember, fetchMembers, updateMember } = useMember();
  const { persistPool } = usePool();
  const [loadbalancerID, setLoadbalancerID] = useState(null);
  const [poolID, setPoolID] = useState(null);
  const [memberID, setMemberID] = useState(null);
  const [members, setMembers] = useState({
    isLoading: false,
    error: null,
    items: [],
  });
  const [member, setMember] = useState({
    isLoading: false,
    error: null,
    item: null,
  });
  const [showExistingMembers, setShowExistingMembers] = useState(false);
  const [searchTerm, setSearchTerm] = useState(null);
  const [filteredItems, setFilteredItems] = useState([]);

  useEffect(() => {
    // get the lb
    const params = matchParams(props);
    const lbID = params.loadbalancerID;
    const plID = params.poolID;
    const mID = params.memberID;
    setLoadbalancerID(lbID);
    setPoolID(plID);
    setMemberID(mID);
  }, []);

  useEffect(() => {
    if (memberID) {
      loadMember();
    }
  }, [memberID]);

  useEffect(() => {
    if (member.item) {
      loadMembers();
    }
  }, [member.item]);

  // load all members so they can be displayed
  useEffect(() => {
    const newItems = filterItems(searchTerm, members.items);
    setFilteredItems(newItems);
  }, [searchTerm, members]);

  const loadMember = () => {
    Log.debug("fetching member to edit");
    setMember({ ...member, isLoading: true, error: null });
    fetchMember(loadbalancerID, poolID, memberID)
      .then((data) => {
        setMember({
          ...member,
          isLoading: false,
          item: data.member,
          error: null,
        });
      })
      .catch((error) => {
        setMember({ ...member, isLoading: false, error: error });
      });
  };

  const loadMembers = () => {
    Log.debug("fetching members for table");
    setMembers({ ...members, isLoading: true });
    fetchMembers(loadbalancerID, poolID)
      .then((data) => {
        // set state saved so it can be edited
        const newItems = data.members || [];
        for (let i = 0; i < newItems.length; i++) {
          newItems[i] = { ...newItems[i], ...{ saved: true } };
        }
        // remove teh member to edit from the list
        if (member.item) {
          const index = newItems.findIndex((item) => item.id == member.item.id);
          if (index >= 0) {
            newItems.splice(index, 1);
          }
        }

        setMembers({
          ...members,
          isLoading: false,
          items: newItems,
          error: null,
        });
      })
      .catch((error) => {
        setMembers({ ...members, isLoading: false, error: error });
      });
  };

  /*
   * Modal stuff
   */
  const [show, setShow] = useState(true);

  const close = (e) => {
    if (e) e.stopPropagation();
    setShow(false);
  };

  const restoreUrl = () => {
    if (!show) {
      // get the lb
      const params = matchParams(props);
      const lbID = params.loadbalancerID;
      props.history.replace(
        `/loadbalancers/${lbID}/show?${searchParamsToString(props)}`
      );
    }
  };

  /**
   * Form stuff
   */
  const [initialValues, setInitialValues] = useState({});
  const [formErrors, setFormErrors] = useState(null);
  const [submitResults, setSubmitResults] = useState({});

  const validate = (values) => {
    return true;
  };

  const onSubmit = (values) => {
    setFormErrors(null);
    // parse nested keys to objects
    // from values like member[XYZ][name]="arturo" to {XYZ:{name:"arturo"}}
    const newValues = parseNestedValues(values);
    return updateMember(loadbalancerID, poolID, memberID, newValues[memberID])
      .then((response) => {
        addNotice(
          <React.Fragment>
            Member <b>{response.data.name}</b> ({response.data.id}) is being
            updated.
          </React.Fragment>
        );
        // update pool
        persistPool(loadbalancerID, poolID);
        close();
      })
      .catch((error) => {
        const results =
          error.response && error.response.data && error.response.data.results;
        setFormErrors(formErrorMessage(error));
        if (results) {
          setSubmitResults(results);
        }
      });
  };

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

                <div className="edit-members-container">
                  <div className="new-members-container">
                    {member.item && (
                      <NewEditMemberListItem
                        member={member.item}
                        key={member.item.id}
                        index={0}
                        edit
                      />
                    )}
                  </div>
                  <div className="existing-members">
                    <div className="display-flex">
                      <div
                        className="action-link"
                        onClick={() =>
                          setShowExistingMembers(!showExistingMembers)
                        }
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
  );
};

export default EditMember;
