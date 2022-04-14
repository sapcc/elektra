/* eslint no-console:0 */
import ReactDOM from "react-dom"
import { Link } from "react-router-dom"

// replace service breadcrum with this component
// to avoid to load the whole page
const Title = () => {
  let title = React.useMemo(() => {
    let elem = document.getElementsByClassName("page-title")
    if (elem && elem[0]) elem = elem[0]
    if (!elem) return null
    elem.innerHTML = ""
    return elem
  }, [])

  if (!title) return
  return ReactDOM.createPortal(
    <span>
      <i className="fa fa-angle-right" />
      &nbsp;
      <Link to="/">Security Groups</Link>
    </span>,
    title
  )
}

export default Title
