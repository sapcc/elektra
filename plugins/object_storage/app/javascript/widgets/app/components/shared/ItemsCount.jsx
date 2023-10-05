import React from "react"

const ItemsCount = ({ count }) => (
  <small className="info-text">
    {count} item{count > 1 ? "s" : ""}
  </small>
)

export default ItemsCount
