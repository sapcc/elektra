import React from "react"
import PropTypes from "prop-types"

const FileIcon = ({ item }) => {
  let iconName = "fa-file-o"
  let title = "Object"

  if (item.subdir || item.folder) {
    iconName = "fa-folder"
    title = "Directory"
  } else if (item.content_type && item.content_type.startsWith("text/")) {
    iconName = "fa-file-text-o"
    title = "Text"
  } else if (item.content_type && item.content_type.startsWith("video/")) {
    iconName = "fa-file-video-o"
    title = "Video"
  } else if (item.content_type && item.content_type === "application/pdf") {
    iconName = "fa-file-pdf-o"
    title = "PDF"
  } else if (item.content_type && item.content_type.startsWith("image")) {
    iconName = "fa-file-image-o"
    title = "Image"
  } else if (
    item.content_type &&
    item.content_type === "application/octet-stream" &&
    /^.*\.docx?$/.test(item.name)
  ) {
    iconName = "fa-file-word-o"
    title = "Word"
  }

  return <span className={`fa fa-fw ${iconName}`} title={title} />
}

FileIcon.propTypes = {
  item: PropTypes.object,
}

export default FileIcon
