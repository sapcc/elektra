import React, { useMemo, useState, useEffect } from "react"
import {
  Button,
  Collapse,
  Form,
  FormGroup,
  FormControl,
  HelpBlock,
} from "react-bootstrap"
import Select from "react-select"
import { useDispatch, useGlobalState } from "./StateProvider"
import {
  getServiceParams,
  createTag,
  formValidation,
  BASE_PREFIX,
} from "../../lib/hooks/useTag"
import { useFormState, useFormDispatch } from "./FormState"

const NewTag = ({ profileKey, show, cancelCallback }) => {
  const profilesCfg = useGlobalState().config.profiles
  const [validation, setValidation] = useState({})
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
    // validate form
    const isValidForm = formValidation(profilesCfg, formState)
    setValidation(isValidForm)

    // if no valid
    if (Object.keys(isValidForm).length > 0) return
    // collect values and build tag
    const tag = createTag(formState)
    console.log("the new tag: ", tag)
    // TODO: send request
  }

  const onServiceSelectChanged = (options) => {
    // save the option in the formState
    dispatch({ type: "SET_SERVICE", profile: profileKey, service: options })
    // reset the validation
    setValidation({})
  }

  const onCancelClicked = () => {
    // reset service
    dispatch({ type: "REMOVE_SERVICE" })
    // reset the validation
    setValidation({})
    cancelCallback()
  }

  const serviceVars = formState.service?.vars || []

  return (
    <Collapse in={show}>
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
          <FormGroup controlId="service">
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
          </FormGroup>

          <>
            {serviceVars.map((varKey, i) => (
              <FormGroup
                key={i}
                controlId={varKey}
                validationState={validation[varKey] && "error"}
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
                {validation[varKey] &&
                  validation[varKey].map((msg, i) => (
                    <HelpBlock key={i}>{msg}</HelpBlock>
                  ))}
              </FormGroup>
            ))}
          </>

          <div className="new-service-footer">
            <span className="cancel">
              <Button
                bsStyle="default"
                bsSize="small"
                onClick={onCancelClicked}
              >
                Cancel
              </Button>
            </span>
            <Button bsStyle="primary" bsSize="small" onClick={onSaveClick}>
              save
            </Button>
          </div>
        </Form>
      </div>
    </Collapse>
  )
}

export default NewTag
