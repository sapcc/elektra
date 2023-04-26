import React from "react"
import CopyPastePopover from "./shared/CopyPastePopover"
import Log from "./shared/logger"

const StaticTags = ({ tags, shouldPopover }) => {
  Log.debug("render tags")
  return (
    <>
      <div className="static-tags clearfix">
        {tags &&
          tags.map((tag, index) => (
            <div key={index} className="tag">
              <div className="value">
                {shouldPopover && tag.length > 10 ? (
                  <CopyPastePopover text={tag} size={10} shouldCopy={false} />
                ) : (
                  tag
                )}
              </div>
            </div>
          ))}
      </div>
    </>
  )
}

export default StaticTags
