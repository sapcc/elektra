import React from "react"
import { useParams, useHistory, Link, useRouteMatch } from "react-router-dom"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"

const Breadcrumb = ({}) => {
  let { url } = useRouteMatch()
  let { name, objectPath } = useParams()
  let history = useHistory()
  let objectsRoot = url.replace(/([^\/])\/objects.*/, "$1/objects")

  const { value: currentPath, encode } = useUrlParamEncoder(objectPath)

  const items = React.useMemo(
    () => currentPath.split("/").filter((p) => !!p && p !== ""),
    [currentPath]
  )
  const handleClick = React.useCallback((e, i) => {
    e.preventDefault()
    let newPath = items.slice(0, i).join("/")
    if (newPath.length > 0) newPath += "/"
    history.push(`${objectsRoot}/${encode(newPath)}`)
  })

  return (
    <ol className="breadcrumb">
      <li>
        <Link to="/containers">All containers</Link>
      </li>
      <li>
        {items.length === 0 ? (
          name
        ) : (
          <a href="#" onClick={(e) => handleClick(e, 0)}>
            {name}
          </a>
        )}
      </li>

      {items.map((p, i) => (
        <li className="active" key={i}>
          {i < items.length - 1 ? (
            <a href="#" onClick={(e) => handleClick(e, i + 1)}>
              {p}
            </a>
          ) : (
            p
          )}
        </li>
      ))}
    </ol>
  )
}

export default Breadcrumb
