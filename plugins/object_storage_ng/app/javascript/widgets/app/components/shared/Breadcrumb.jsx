import React from "react"
import { useParams, useHistory, Link, useRouteMatch } from "react-router-dom"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"

const regex = new RegExp("(/*[^/]+/)", "g")
const Breadcrumb = ({ count }) => {
  let { url } = useRouteMatch()
  let { name, objectPath } = useParams()
  let history = useHistory()
  let objectsRoot = url.replace(/([^/])\/objects.*/, "$1/objects")

  const { value: currentPath, encode } = useUrlParamEncoder(objectPath)

  const items = React.useMemo(() => {
    let match = currentPath.match(regex)
    if (!match) return []
    return match.map((i) => (i[i.length - 1] === "/" ? i.slice(0, -1) : i))

    //return currentPath.split("/").filter((p) => !!p && p !== "")
  }, [currentPath])
  const handleClick = React.useCallback((e, i) => {
    e.preventDefault()
    let newPath = items.slice(0, i).join("/")
    if (newPath.length > 0) newPath += "/"
    history.push(`${objectsRoot}/${encode(newPath)}`)
  })

  return (
    <div className="breadrumb-with-details">
      <ol className="breadcrumb">
        <li>
          {name ? (
            <Link to="/containers">All containers</Link>
          ) : (
            <>All containers</>
          )}
        </li>
        {name && (
          <li>
            {items.length === 0 ? (
              name && (
                <>
                  <span className="fa fa-fw fa-hdd-o" title="Container" />{" "}
                  {name}
                </>
              )
            ) : (
              <a href="#" onClick={(e) => handleClick(e, 0)}>
                <span className="fa fa-fw fa-hdd-o" title="Container" /> {name}
              </a>
            )}
          </li>
        )}

        {items.map((p, i) => (
          <li className={i === items.length - 1 ? "active" : ""} key={i}>
            {i < items.length - 1 ? (
              <a href="#" onClick={(e) => handleClick(e, i + 1)}>
                <span className="fa fa-fw fa-folder" title="Directory" />
                {p}
              </a>
            ) : (
              <>
                <span className="fa fa-fw fa-folder-open" title="Directory" />{" "}
                {p}
              </>
            )}
          </li>
        ))}
      </ol>
      {count !== undefined && <div className="details">#{count}</div>}
    </div>
  )
}

export default Breadcrumb
