import { Link } from "react-router-dom"

const Tabs = ({ match, location, history, tabsConfig, ...otherProps }) => {
  let tabItems = []
  let tabPanels = []

  for (let index in tabsConfig) {
    let tab = tabsConfig[index]
    let active = location.pathname.indexOf(tab.to) == 0

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
        {React.createElement(
          tab.component,
          Object.assign({}, { active, match, location, history }, otherProps)
        )}
      </div>
    )
  }

  console.log("RENDER tabs")
  return (
    <div>
      <ul className="nav nav-tabs" role="tablist">
        {tabItems}
      </ul>
      <div className="tab-content">{tabPanels}</div>
    </div>
  )
}

export default Tabs
