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
      {props.iconClass ? <i className={props.iconClass}></i> : "Auth Projects"}
    </a>
  )
}

export default ModalLink
