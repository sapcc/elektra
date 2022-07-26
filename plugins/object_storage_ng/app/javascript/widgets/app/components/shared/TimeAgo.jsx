import React from "react"

// const TimeAgo = ({ date, originDate }) => {
//   if (typeof date === "string") {
//     if (date[DataTransfer.length - 1] !== "Z") date += "Z"
//     date = new Date(date)
//   }
//   let ago = (Date.now() - date.getTime()) / 1000

//   if (ago < 60) return <span>{Math.floor(ago)} seconds ago</span>
//   ago = ago / 60

//   if (ago < 60) return <span>{Math.floor(ago)} minutes ago</span>
//   ago = ago / 60

//   if (ago < 24) return <span>{Math.floor(ago)} hours ago</span>
//   ago = ago / 24

//   return <span>{Math.floor(ago)} days ago</span>
// }

const TimeAgo = ({ date, originDate }) => {
  if (typeof date === "string") {
    if (date[DataTransfer.length - 1] !== "Z") date += "Z"
    date = new Date(date)
  }
  let ago = (Date.now() - date.getTime()) / 1000
  let unitName = ""

  if (ago < 60) {
    unitName = "second"
  } else if ((ago = ago / 60) < 60) {
    unitName = "minute"
  } else if ((ago = ago / 60) < 24) {
    unitName = "hour"
  } else {
    ago = ago / 24
    unitName = "day"
  }
  ago = Math.floor(ago)

  return (
    <span>
      {ago} {unitName + (ago > 1 ? "s" : "")} ago
      {originDate && (
        <>
          <br />
          <small className="info-text">{date.toLocaleString()}</small>
        </>
      )}
    </span>
  )
}

export default TimeAgo
