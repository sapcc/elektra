import React, { useMemo, useState } from "react"
import { addNotice } from "lib/flashes"
import {
  Button,
  Form,
  FormGroup,
  FormControl,
  HelpBlock,
} from "react-bootstrap"
import Select from "react-select"
import { useGlobalState } from "./StateProvider"
import {
  getServiceParams,
  composeTag,
  validateForm,
  BASE_PREFIX,
  errorMessage,
} from "../../lib/hooks/useTag"
import { useFormState, useFormDispatch } from "./FormState"
import { createTag } from "../actions/tags"

const NewTag = ({ profileKey, onClose }) => {
  const profilesCfg = useGlobalState().config.profiles
  const [formValidation, setFormValidation] = useState({})
  const [apiError, setApiError] = useState(null)
  const [saving, setSaving] = useState(false)
  const dispatch = useFormDispatch()
  const formState = useFormState()

  const profilePrefix = useMemo(
    () => `${BASE_PREFIX}:${profileKey}`,
    [profileKey]
  )

  // create select options
  const selectOptions = useMemo(() => {
    if (!profilesCfg) return []

    const foundServices = profilesCfg[profilePrefix] || []
    return Object.keys(foundServices).map((serviceKey) => {
      // serviceKey is in the form of keyname:$1:$2
      // getServiceParams return the keyname and the vars $1,$2 as []
      const serviceParams = getServiceParams(serviceKey)
      return {
        value: serviceParams.name,
        label: `${serviceParams.name} (${profilesCfg[profilePrefix]?.[serviceKey]?.description})`,
        key: serviceParams.key,
        vars: serviceParams.vars,
      }
    })
  }, [profilesCfg])

  const onSaveClick = () => {
    setSaving(true)
    // validate form
    const isValidForm = validateForm(profilesCfg, formState)
    setFormValidation(isValidForm)

    // if no valid
    if (Object.keys(isValidForm).length > 0) {
      setSaving(false)
      return
    }
    // collect values and build tag
    const tag = composeTag(formState)

    return createTag(tag)
      .then((response) => {
        if (response) {
          addNotice(
            <>
              Access profile <b>{response.tag}</b> created.
            </>
          )
        }
        // fetch TAGS on close adding true
        onClose({ reload: true })
      })
      .catch((error) => {
        setSaving(false)
        setApiError(errorMessage(error))
      })
  }

  const onServiceSelectChanged = (options) => {
    // save the option in the formState
    dispatch({ type: "SET_SERVICE", profile: profileKey, service: options })
    // reset the validation
    setFormValidation({})
  }

  const serviceVars = formState.service?.vars || []

  return (
    <>
      <div className="new-service-container">
        <div className="new-service-title">
          <b>
            Add a new
            <i className="capitalize">{` ${profileKey} `}</i>
            Access Profile
          </b>
        </div>

        <Form
          autoComplete="off"
          onSubmit={(e) => e.preventDefault()}
          onKeyDown={(e) => {
            // no submit on enter pressed
            if (e.key === 13) {
              e.preventDefault()
              e.stopPropagation()
              return false
            }
          }}
        >
          <FormGroup
            controlId="service"
            validationState={formValidation["service"] && "error"}
          >
            <Select
              className="basic-single"
              classNamePrefix="select"
              isDisabled={false}
              isRtl={false}
              isSearchable={true}
              name="service-action"
              value={formState.service}
              onChange={onServiceSelectChanged}
              options={selectOptions}
              closeMenuOnSelect={true}
              placeholder="Select Service and Action"
            />
            {formValidation["service"] &&
              formValidation["service"].map((msg, i) => (
                <HelpBlock key={i}>{msg}</HelpBlock>
              ))}
          </FormGroup>

          <>
            {serviceVars.map((varKey, i) => (
              <FormGroup
                key={i}
                controlId={varKey}
                validationState={formValidation[varKey] && "error"}
              >
                <FormControl
                  type="text"
                  value={formState.attrs[varKey] || ""}
                  placeholder={
                    profilesCfg[profilePrefix]?.[formState.service.key]?.[
                      varKey
                    ] || "Enter value"
                  }
                  onChange={(e) => {
                    dispatch({
                      type: "SET_SERVICE_ATTR",
                      key: varKey,
                      value: e.target.value,
                    })
                  }}
                />
                {formValidation[varKey] &&
                  formValidation[varKey].map((msg, i) => (
                    <HelpBlock key={i}>{msg}</HelpBlock>
                  ))}
              </FormGroup>
            ))}
          </>

          {apiError && (
            <div className="api-error text-danger">
              <span className="fa fa-fw fa-exclamation-triangle"></span>
              <div className="api-error-text">{apiError}</div>
            </div>
          )}

          <div className="new-service-footer">
            <span className="cancel">
              <Button
                bsStyle="default"
                bsSize="small"
                disabled={saving}
                onClick={onClose}
              >
                Cancel
              </Button>
            </span>
            <Button
              bsStyle="primary"
              bsSize="small"
              disabled={saving}
              onClick={onSaveClick}
            >
              {saving && <span className="spinner"></span>}
              save
            </Button>
          </div>
        </Form>
      </div>
    </>
  )
}

export default NewTag
