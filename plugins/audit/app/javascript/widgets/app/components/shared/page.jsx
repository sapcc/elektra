import React from "react"
export default ({ page, label, disabled, currentPage, handlePageChange }) => {
  let className = ""
  if (disabled) className += "disabled "
  if (page == currentPage) className += "active "

  return (
    <li className={className}>
      <a
        href="#"
        onClick={(e) => {
          e.preventDefault()
          disabled ? null : handlePageChange(page)
        }}
      >
        {label ? label : page}
      </a>
    </li>
  )
}
