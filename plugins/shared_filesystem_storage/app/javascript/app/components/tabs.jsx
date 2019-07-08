import { Link } from 'react-router-dom'

/***********************************
 * This component renders a tabed content
 **********************************/
export default ({match, location, history, tabsConfig, ...otherProps}) => {
  const tabItems = [];
  let tabPanel;

  for (let index in tabsConfig) {
    const tab = tabsConfig[index];
    const isActive = location.pathname.indexOf(tab.to) == 0;

    tabItems.push(
      <li className={isActive ? 'active' : ''} key={`tab_${index}`}>
        <Link to={tab.to} replace={true}>{tab.label}</Link>
      </li>
    );

    if (isActive) {
      tabPanel = (
        <div className='tab-pane active'>
          {React.createElement(
            tab.component,
            { active: true, match, location, history, ...otherProps },
          )}
        </div>
      );
    }
  }

  return (
    <div>
      <ul className="nav nav-tabs" role="tablist">{tabItems}</ul>
      <div className="tab-content">{tabPanel}</div>
    </div>
  )
}
