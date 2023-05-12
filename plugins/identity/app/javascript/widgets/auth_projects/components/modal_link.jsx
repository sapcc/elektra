import React from "react"

const ModalLink = (props) => {
  return (
    <a
      href="#"
      onClick={(e) => {
        e.preventDefault()
        props.toggleModal()
      }}
    >
    <i className="fa fa-th-list"></i> Projects
    </a>
  )
}

export default ModalLink
