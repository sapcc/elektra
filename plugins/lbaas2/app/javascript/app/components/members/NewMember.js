import React, { useState, useEffect } from "react";
import { Modal, Button } from "react-bootstrap";
import useCommons from "../../../lib/hooks/useCommons";
import { Form } from "lib/elektra-form";
import useMember, {
  filterItems,
  parseNestedValues,
} from "../../../lib/hooks/useMember";
import uniqueId from "lodash/uniqueId";
import { addNotice } from "lib/flashes";
import NewEditMemberListItem from "./NewEditMemberListItem";
import usePool from "../../../lib/hooks/usePool";
import FormSubmitButton from "../shared/FormSubmitButton";
import Log from "../shared/logger";
import { SearchField } from "lib/components/search_field";
import MembersTable from "./MembersTable";
import { Tooltip, OverlayTrigger } from "react-bootstrap";
import { Link } from "react-router-dom";

const generateMember = (name, address) => {
  return {
    id: uniqueId("member_"),
    name: name || "",
    address: address || "",
    backup: false,
  };
};
const AddNewMemberButton = ({ disabled, addMembersCallback }) => {
  return (
    <>
      {disabled ? (
        <OverlayTrigger
          placement="top"
          overlay={
            <Tooltip id={uniqueId("tooltip-")}>
              You reach the maximum of 5 new members
            </Tooltip>
          }
        >
          <Link
            to={""}
            className="btn btn-default btn-xs"
            disabled={true}
            onClick={(e) => {
              e.preventDefault();
            }}
          >
            Add another
          </Link>
        </OverlayTrigger>
      ) : (
        <Link
          to={""}
          className="btn btn-default btn-xs"
          onClick={(e) => {
            e.preventDefault();
            addMembersCallback();
          }}
        >
          Add another
        </Link>
      )}
    </>
  );
};

const NewMember = (props) => {
  const { searchParamsToString, matchParams, formErrorMessage, errorMessage } =
    useCommons();
  const { fetchServers, create, fetchMembers } = useMember();
  const { persistPool } = usePool();
  const [servers, setServers] = useState({
    isLoading: false,
    error: null,
    items: [],
  });
  const [members, setMembers] = useState({
    isLoading: false,
    error: null,
    items: [],
  });
  const [loadbalancerID, setLoadbalancerID] = useState(null);
  const [poolID, setPoolID] = useState(null);
  const [newMembers, setNewMembers] = useState([generateMember()]);
  const [showExistingMembers, setShowExistingMembers] = useState(false);
  const [searchTerm, setSearchTerm] = useState(null);
  const [filteredItems, setFilteredItems] = useState([]);

  useEffect(() => {
    // get the lb
    const params = matchParams(props);
    const lbID = params.loadbalancerID;
    const plID = params.poolID;
    setLoadbalancerID(lbID);
    setPoolID(plID);
  }, []);

  useEffect(() => {
    if (!loadbalancerID && !poolID) return;
    Log.debug("fetching servers for select");
    // get servers for the select
    setServers({ ...servers, isLoading: true });
    fetchServers(loadbalancerID, poolID)
      .then((data) => {
        setServers({
          ...servers,
          isLoading: false,
          items: data.servers,
          error: null,
        });
      })
      .catch((error) => {
        setServers({
          ...servers,
          isLoading: false,
          error: errorMessage(error),
        });
      });
    // get the existing members
    setMembers({ ...members, isLoading: true });
    fetchMembers(loadbalancerID, poolID)
      .then((data) => {
        const newItems = data.members || [];
        for (let i = 0; i < newItems.length; i++) {
          newItems[i] = { ...newItems[i], ...{ saved: true } };
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
  }, [loadbalancerID, poolID]);

  useEffect(() => {
    const newItems = filterItems(searchTerm, members.items);
    setFilteredItems(newItems);
  }, [searchTerm, members]);

  /**
   * Modal stuff
   */
  const [show, setShow] = useState(true);

  const close = (e) => {
    if (e) e.stopPropagation();
    setShow(false);
  };

  const restoreUrl = () => {
    if (!show) {
      props.history.replace(
        `/loadbalancers/${loadbalancerID}/show?${searchParamsToString(props)}`
      );
    }
  };

  /**
   * Form stuff
   */
  const [initialValues, setInitialValues] = useState({});
  const [formErrors, setFormErrors] = useState(null);

  const validate = (values) => {
    return newMembers && newMembers.length > 0;
  };

  const onSubmit = (values) => {
    setFormErrors(null);
    // filter items from the form context which are removed from the newMember list
    const filtered = Object.keys(values)
      .filter((key) => {
        let found = false;
        for (let i = 0; i < newMembers.length; i++) {
          if (found) {
            break;
          }
          found = key.includes(newMembers[i].id);
        }
        return found;
      })
      .reduce((obj, key) => {
        obj[key] = values[key];
        return obj;
      }, {});

    // parse nested keys to objects
    // from values like member[XYZ][name]="arturo" to {XYZ:{name:"arturo"}}
    const newMemberObjs = parseNestedValues(filtered);

    let batchMembers = [];
    Object.keys(newMemberObjs).forEach((key) => {
      batchMembers.push(newMemberObjs[key]);
    });

    // save the entered values in case of error
    setInitialValues(filtered);
    return create(loadbalancerID, poolID, batchMembers)
      .then((response) => {
        if (response && response.data) {
          if (batchMembers.length == 1) {
            addNotice(
              <React.Fragment>
                Member <b>{response.data.name}</b> ({response.data.id}) is being
                created.
              </React.Fragment>
            );
          } else {
            addNotice(
              <React.Fragment>Members are being created.</React.Fragment>
            );
          }
        }
        // fetch the Members and the pool again
        persistPool(loadbalancerID, poolID);
        close();
      })
      .catch((error) => {
        setFormErrors(errorMessage(error));
      });
  };

  const addMembers = () => {
    const newExtMembers = generateMember();
    let items = newMembers.slice();
    items.push(newExtMembers);
    // add values
    setNewMembers(items);
  };

  const onRemoveMember = (id) => {
    const index = newMembers.findIndex((item) => item.id == id);
    if (index < 0) {
      return;
    }
    let newItems = newMembers.slice();
    newItems.splice(index, 1);
    setNewMembers(newItems);
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

          <div className="new-members-container">
            <div className="new-members">
              {newMembers.length > 0 ? (
                <>
                  {newMembers.map((member, index) => (
                    <NewEditMemberListItem
                      member={member}
                      key={member.id}
                      index={index}
                      onRemoveMember={onRemoveMember}
                      servers={servers}
                    />
                  ))}
                </>
              ) : (
                <p>"No new members added yet."</p>
              )}

              <div className="add-more-section">
                <AddNewMemberButton
                  disabled={newMembers.length > 4}
                  addMembersCallback={addMembers}
                />
              </div>
            </div>

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
  );
};

export default NewMember;
