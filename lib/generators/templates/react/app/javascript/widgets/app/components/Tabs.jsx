import React from "react"
import { Link, useHistory, useLocation } from "react-router-dom"

/***********************************
 * This component renders a tabed content
 **********************************/

const Tabs = ({ tabsConfig, ...otherProps }) => {
  const location = useLocation()

  const [nav, content] = React.useMemo(() => {
    let tabItems = []
    let tabPanels = []
    for (let index in tabsConfig) {
      let tab = tabsConfig[index]
      let active = location.pathname.indexOf(tab.to) == 0
      let Component = tab.component

      // collect tab items
      tabItems.push(
        <li className={active ? "active" : ""} key={`tab_${index}`}>
          <Link to={tab.to} replace={true}>
            {tab.label}
          </Link>
        </li>
      )
      // collect tab panels
      tabPanels.push(
        <div
          className={"tab-pane " + (active ? "active" : "")}
          key={`panel_${index}`}
        >
          <Component>{otherProps}</Component>
        </div>
      )
    }
    return [tabItems, tabPanels]
  }, [location, tabsConfig])

  return (
    <div>
      <ul className="nav nav-tabs" role="tablist">
        {nav}
      </ul>
      <div className="tab-content">{content}</div>
    </div>
  )
}

export default Tabs
