import React from "react"

const FileIcon = ({ item }) => {
  let iconName = "fa-file-o"
  let title = "Object"

  if (item.isFolder || item.folder) {
    iconName = "fa-folder"
    title = "Directory"
  } else if (item.contentType && item.contentType.startsWith("text/")) {
    iconName = "fa-file-text-o"
    title = "Text"
  } else if (item.contentType && item.contentType === "application/pdf") {
    iconName = "fa-file-pdf-o"
    title = "PDF"
  } else if (item.contentType && item.contentType.startsWith("image")) {
    iconName = "fa-file-image-o"
    title = "Image"
  } else if (
    item.contentType &&
    item.contentType === "application/octet-stream"
  ) {
    iconName = "fa-file-word-o"
    title = "Word"
  }

  return <span className={`fa fa-fw ${iconName}`} title={title} />
}

export default FileIcon
