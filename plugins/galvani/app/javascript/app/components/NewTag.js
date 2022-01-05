import React, { useMemo, useState, useEffect } from "react"
import { Button, Collapse, FormGroup, FormControl } from "react-bootstrap"
import Select from "react-select"
import { useDispatch, useGlobalState } from "./StateProvider"
import { getServiceParams } from "../../lib/hooks/useTag"

const NewTag = ({ profileName, show, cancelCallback }) => {
  const profilesCfg = useGlobalState().config.profiles
  const [showVarsInput, setShowVarsInput] = useState(false)

  const [serviceValue, setServiceValue] = useState(null)
  const [serviceVarPlaceholder, setServiceVarPlaceholder] =
    useState("Enter text")

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
    // need to check if the profileAction has a variable to set
    setServiceValue(options)
    setShowVarsInput(options.hasVars || false)
    console.log("selected option: ", options)
  }

  const onChangeServiceVar = () => {}

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
            isClearable={true}
            isRtl={false}
            isSearchable={true}
            name="service-action"
            onChange={onServiceSelectChanged}
            options={selectOptions}
            value={serviceValue}
            closeMenuOnSelect={true}
            placeholder="Select Service and Action"
          />
        </FormGroup>

        {showVarsInput && (
          <FormGroup
            controlId="serviceVar"
            // validationState={this.getValidationState()}
          >
            <FormControl
              type="text"
              // value={this.state.value}
              placeholder={serviceVarPlaceholder}
              onChange={onChangeServiceVar}
            />
            <FormControl.Feedback />
            {/* <HelpBlock>Validation is based on string length.</HelpBlock> */}
          </FormGroup>
        )}

        <div className="new-service-footer">
          <span className="cancel">
            <Button bsStyle="default" bsSize="small" onClick={cancelCallback}>
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
