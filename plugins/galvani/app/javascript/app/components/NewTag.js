import React, { useMemo, useState, useEffect } from "react"
import { Button, Collapse, FormGroup, FormControl } from "react-bootstrap"
import Select from "react-select"
import { useDispatch, useGlobalState } from "./StateProvider"
import { getServiceParams } from "../../lib/hooks/useTag"
import { useFormState, useFormDispatch } from "./FormState"

const NewTag = ({ profileName, show, cancelCallback }) => {
  const profilesCfg = useGlobalState().config.profiles
  const [showVarsInput, setShowVarsInput] = useState(false)
  const [serviceVarPlaceholder, setServiceVarPlaceholder] =
    useState("Enter text")
  const dispatch = useFormDispatch()
  const formState = useFormState()

  // reset selected tag on hide
  useEffect(() => {
    // load when the configuration is loaded
    if (!show) {
      setShowVarsInput(false)
    }
  }, [show])

  // create select options
  const selectOptions = useMemo(() => {
    if (!profilesCfg) return []

    // find profile key to avoid errors in case galvani root prefix changes
    const foundProfileKey = Object.keys(profilesCfg).find((i) =>
      i.includes(profileName)
    )
    const foundServices = profilesCfg[foundProfileKey] || []

    return Object.keys(foundServices).map((serviceKey) => {
      const serviceParams = getServiceParams(serviceKey)
      return {
        value: serviceParams.name,
        label: `${serviceParams.name} (${profilesCfg[foundProfileKey][serviceKey].description})`,
        hasVars: serviceParams.hasVars,
        varPlaceholder: `${
          profilesCfg[foundProfileKey][serviceKey].$1 || "Enter text"
        }`,
      }
    })
  }, [profilesCfg])

  const onSaveClick = () => {}

  const onServiceSelectChanged = (options) => {
    dispatch({ type: "SET_SERVICE", service: options })

    // need to check if the profileAction has a variable to set
    setShowVarsInput(options.hasVars || false)
    setServiceVarPlaceholder(options.varPlaceholder)
  }

  const onChangeServiceVar = (e) => {
    dispatch({ type: "SET_SERVICE_ATTR", attr: e.target.value })
  }

  const onCancelClicked = () => {
    // reset values when closing
    dispatch({ type: "REMOVE_SERVICE" })
    cancelCallback()
  }

  return (
    <Collapse in={show}>
      <div className="new-service-container">
        <div className="new-service-title">
          <b>
            Add a new
            <i className="capitalize">{` ${profileName} `}</i>
            Access Profile
          </b>
        </div>

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

        <Collapse in={showVarsInput}>
          <FormGroup
            controlId="serviceVar"
            // validationState={this.getValidationState()}
          >
            <FormControl
              type="text"
              value={formState.attr}
              placeholder={serviceVarPlaceholder}
              onChange={onChangeServiceVar}
            />
            <FormControl.Feedback />
            {/* <HelpBlock>Validation is based on string length.</HelpBlock> */}
          </FormGroup>
        </Collapse>

        <div className="new-service-footer">
          <span className="cancel">
            <Button bsStyle="default" bsSize="small" onClick={onCancelClicked}>
              Cancel
            </Button>
          </span>
          <Button bsStyle="primary" bsSize="small" onClick={onSaveClick}>
            save
          </Button>
        </div>
      </div>
    </Collapse>
  )
}

export default NewTag
