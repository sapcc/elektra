import React from "react"
import { Button, Form, FormRow, TextInput, ButtonRow } from "@cloudoperators/juno-ui-components"

export function NewForm({ onSubmit, onCancel }) {
  const [formData, setFormData] = React.useState({})

  return (
    <Form>
      <FormRow required>
        <TextInput
          label="Name"
          name="name"
          required
          data-target="name-text-input"
          onChange={(oEvent) => {
            console.log("Name changed:", oEvent.target.value)
            console.log("Form data before update:", formData)
            setFormData({ ...formData, name: oEvent.target.value })
          }}
        />
      </FormRow>
      <FormRow required>
        <TextInput
          label="Description"
          name="description"
          required
          data-target="name-text-input"
          onChange={(oEvent) => {
            setFormData({ ...formData, description: oEvent.target.value })
          }}
        />
      </FormRow>
      <ButtonRow>
        <Button label="Save" onClick={() => onSubmit(formData)} variant="primary" data-target="save-secret-btn" />
        <Button label="Cancel" onClick={onCancel} />
      </ButtonRow>
    </Form>
  )
}
