import React from "react"

const CachedInfoPopoverContentContainers = ({ containers }) => {
  return containers.length > 0 ? (
    containers.map((container, index) => (
      <div key={index}>
        <div className="row">
          <div className="col-md-12">
            {container.ref && (
              <>
                <div>{container.name}:</div>
                <div className="word-break">
                  <a href={container.ref} target="_blank" rel="noreferrer">
                    {container.ref}
                  </a>
                </div>
              </>
            )}
            {container.refList && (
              <>
                <div>{container.name}:</div>
                <div className="list">
                  {container.refList.map((item, refListIndex) => (
                    <div className="list-entry word-break" key={refListIndex}>
                      <a href={item} target="_blank" rel="noreferrer">
                        {item}
                      </a>
                    </div>
                  ))}
                </div>
              </>
            )}
          </div>
        </div>
        {index === containers.length - 1 ? "" : <hr />}
      </div>
    ))
  ) : (
    <p>No Containers Found</p>
  )
}

export default CachedInfoPopoverContentContainers
