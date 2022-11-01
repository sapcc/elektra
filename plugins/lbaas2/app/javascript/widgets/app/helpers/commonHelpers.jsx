import React from "react"

export const errorMessage = (error) => {
  const err = error
  return (err.data && (err.data.errors || err.data.error)) || err.message
}

export const createNameTag = (name) => {
  return name ? (
    <React.Fragment>
      <b>name:</b> {name} <br />
    </React.Fragment>
  ) : (
    ""
  )
}
