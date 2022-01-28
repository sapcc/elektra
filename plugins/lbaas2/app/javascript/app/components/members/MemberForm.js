import React, {
  useState,
  forwardRef,
  useImperativeHandle,
  useEffect,
} from "react"
import { Form, Tooltip, OverlayTrigger } from "react-bootstrap"
import { useFormState, useFormDispatch, generateMemberItem } from "./FormState"
import NewEditMemberListItem from "./NewEditMemberListItem"
import uniqueId from "lodash/uniqueId"
import { Link } from "react-router-dom"
import { ErrorsList } from "lib/elektra-form"
import { addNotice } from "lib/flashes"
import useCommons from "../../../lib/hooks/useCommons"
import useMember from "../../../lib/hooks/useMember"
import usePool from "../../../lib/hooks/usePool"

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
              e.preventDefault()
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
            e.preventDefault()
            addMembersCallback()
          }}
        >
          Add another
        </Link>
      )}
    </>
  )
}

const validate = (items) => {
  let isValid = true
  if (items && Array.isArray(items)) {
    items.forEach((item) => {
      if (!item.name || item.name.length == 0) {
        isValid = false
      }
      if (!item.address || item.address.length == 0) {
        isValid = false
      }
      if (!item.protocol_port || item.protocol_port.length == 0) {
        isValid = false
      }
    })
  }

  console.log("VALID: ", isValid)

  return isValid
}

const MemberForm = (
  { loadbalancerID, poolID, servers, onFormCallback },
  ref
) => {
  const state = useFormState()
  const dispatch = useFormDispatch()
  const [formErrors, setFormErrors] = useState(null)
  const { create, persistMembers } = useMember()
  const { persistPool } = usePool()
  const { errorMessage } = useCommons()

  const addMembers = () => {
    const item = generateMemberItem()
    dispatch({
      type: "ADD_ITEM",
      item: item,
    })
  }

  useImperativeHandle(ref, () => ({
    onSubmit() {
      if (!validate(state.items)) {
        return onFormCallback({ isSubmitting: false, isValid: false })
      }
      setFormErrors(null)
      onFormCallback({ isSubmitting: true, isValid: true })
      console.log("ITEMS: ", state.items)
      return create(loadbalancerID, poolID, state.items)
        .then((response) => {
          onFormCallback({ isSubmitting: true, isValid: false })
          if (response && response.data) {
            if (state.items.length == 1) {
              addNotice(
                <React.Fragment>
                  Member <b>{response.data.name}</b> ({response.data.id}) is
                  being created.
                </React.Fragment>
              )
            } else {
              addNotice(
                <React.Fragment>Members are being created.</React.Fragment>
              )
            }
          }
          // update pool info
          persistPool(loadbalancerID, poolID)
          // reload members list if batch update
          if (state.items.length > 1) {
            persistMembers(loadbalancerID, poolID)
          }
          onFormCallback({ shouldClose: true })
        })
        .catch((error) => {
          onFormCallback({ isSubmitting: false, isValid: true })
          setFormErrors(errorMessage(error))
        })
    },
  }))

  useEffect(() => {
    return onFormCallback({
      isSubmitting: false,
      isValid: validate(state.items),
    })
  }, [JSON.stringify(state.items)])

  return (
    <Form autoComplete="off" onSubmit={(e) => e.preventDefault()}>
      {formErrors && (
        <div className="alert alert-error">
          <ErrorsList errors={formErrors} />
        </div>
      )}

      <div className="new-members-container">
        <div className="new-members">
          {state.items.length > 0 ? (
            <>
              {state.items.map((member, index) => (
                <NewEditMemberListItem
                  id={member.id}
                  key={member.id}
                  index={index}
                  servers={servers}
                />
              ))}
            </>
          ) : (
            <p>No new members added yet.</p>
          )}

          <div className="add-more-section">
            <AddNewMemberButton
              disabled={state.items.length > 4}
              addMembersCallback={addMembers}
            />
          </div>
        </div>
      </div>
    </Form>
  )
}

export default forwardRef(MemberForm)
