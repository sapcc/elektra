import React, { useMemo } from "react"
import { Button, Collapse } from "react-bootstrap"
import Select from "react-select"

const NewTag = ({ profilekey, items, show, cancelCallback }) => {
  // remove services without tags
  const displayItems = useMemo(() => {
    if (!items) return []
    return Object.keys(items).map((key) => {
      return { value: key, label: `${key} (${items[key].description})` }
    })
  }, [items])

  const onSaveClick = () => {}
  const onSelectChanged = () => {}

  return (
    <Collapse in={show}>
      <div className="new-service-container">
        <div className="new-service-title">
          <b>
            Add a new
            <i className="capitalize">{` ${profilekey} `}</i>
            Access Profile
          </b>
        </div>
        <Select
          className="basic-single"
          classNamePrefix="select"
          isDisabled={false}
          isClearable={true}
          isRtl={false}
          isSearchable={true}
          name="service-action"
          onChange={onSelectChanged}
          options={displayItems}
          // value={value}
          closeMenuOnSelect={true}
          placeholder="Select Service and Action"
        />
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
