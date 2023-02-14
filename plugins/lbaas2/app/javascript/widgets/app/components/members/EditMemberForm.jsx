import React, {
  useState,
  forwardRef,
  useImperativeHandle,
  useEffect,
} from "react"
import { Form, Tooltip, OverlayTrigger } from "react-bootstrap"
import { useFormState, useFormDispatch, generateMemberItem } from "./FormState"
import NewEditMemberListItem from "./NewEditMemberListItem"

import { ErrorsList } from "lib/elektra-form"
import { addNotice } from "lib/flashes"
import useMember, {
  validateForm,
  formAttrForSubmit,
} from "../../lib/hooks/useMember"
import usePool from "../../lib/hooks/usePool"
import Log from "../shared/logger"
import ErrorPage from "../ErrorPage"
import { errorMessage } from "../../helpers/commonHelpers"

const EditMemberForm = (
  { loadbalancerID, poolID, memberID, onFormCallback },
  ref
) => {
  const state = useFormState()
  const dispatch = useFormDispatch()
  const [formErrors, setFormErrors] = useState(null)
  const { persistPool } = usePool()
  const { fetchMember, updateMember } = useMember()
  const [isLoading, setIsLoading] = useState(false)
  const [errorMsg, setErrorMsg] = useState(null)

  useEffect(() => {
    if (memberID && loadbalancerID && poolID) {
      loadMember()
    }
  }, [memberID, loadbalancerID, poolID])

  const loadMember = () => {
    Log.debug("fetching member to edit")
    setIsLoading(true)
    setErrorMsg(null)
    fetchMember(loadbalancerID, poolID, memberID)
      .then((data) => {
        setIsLoading(false)
        setErrorMsg(null)
        dispatch({
          type: "ADD_ITEM",
          item: data.member,
        })
      })
      .catch((error) => {
        setIsLoading(false)
        setErrorMsg(error)
      })
  }

  useImperativeHandle(ref, () => ({
    onSubmit() {
      if (!validateForm(state.items)) {
        return onFormCallback({ isSubmitting: false, isValid: false })
      }
      const memberItems = formAttrForSubmit(state.items)
      setFormErrors(null)
      onFormCallback({ isSubmitting: true, isValid: true })
      return updateMember(loadbalancerID, poolID, memberID, memberItems)
        .then((response) => {
          addNotice(
            <React.Fragment>
              Member <b>{response.data.name}</b> ({response.data.id}) is being
              updated.
            </React.Fragment>
          )
          // update pool
          persistPool(loadbalancerID, poolID)
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
      isValid: validateForm(state.items),
    })
  }, [JSON.stringify(state.items)])

  return (
    <>
      {errorMsg ? (
        <ErrorPage
          headTitle="Edit Member"
          error={errorMsg}
          onReload={loadMember}
        />
      ) : (
        <>
          {isLoading ? (
            <span className="spinner" />
          ) : (
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
                          servers={[]}
                          edit={true}
                        />
                      ))}
                    </>
                  ) : (
                    <p>No new members added yet.</p>
                  )}
                </div>
              </div>
            </Form>
          )}
        </>
      )}
    </>
  )
}

export default forwardRef(EditMemberForm)
