import React from "react"
import {
  Button,
  Form,
  FormRow,
  TextInput,
  ButtonRow,
  Textarea,
  DateTimePicker,
} from "@cloudoperators/juno-ui-components"

export function NewForm({ onSubmit, onCancel, setError }) {
  const [formData, setFormData] = React.useState({})

  return (
    <Form>
      <FormRow>
        <TextInput
          label="Name"
          name="name"
          required
          onChange={(oEvent) => {
            console.log("Form data before update:", formData)
            setFormData({ ...formData, name: oEvent.target.value })
          }}
        />
      </FormRow>
      <FormRow>
        <Textarea
          label="Description"
          name="description"
          required
          onChange={(oEvent) => {
            setFormData({ ...formData, description: oEvent.target.value })
          }}
        />
      </FormRow>
      <FormRow>
        <DateTimePicker
          label="Expires At"
          name="expires_at"
          onChange={(selectedDate) => {
            const currentDate = new Date()
            let selectedDateTime = new Date(selectedDate)
            if (isNaN(selectedDateTime.getTime())) {
              return
            } else if (selectedDateTime < currentDate) {
              setError("Selected date is in the past")
              return
            } else {
              selectedDateTime.setHours(23, 59, 59)
              setFormData({ ...formData, expires_at: selectedDateTime.toISOString() })
            }
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
