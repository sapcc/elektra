ReactTabs = ({tabsConfig, activeTabUid, onSelect}) ->
  return null unless tabsConfig and tabsConfig.length

  if tabsConfig.length==1
    React.createElement 'div',   null,
      tabsConfig[0].content
  else
    activeTabUid ||= tabsConfig[0].uid
    tabs = []
    panels = []
    for tab in tabsConfig
      tabs.push(
        React.createElement 'li',  
          key: "#{tab.uid}_tab",
          role: "presentation",
          className: ("active" if activeTabUid==tab.uid),
          React.createElement 'a',  
            href: "##{tab.uid}",
            "aria-controls": "home",
            role: "tab",
            "data-toggle": "tab",
            onClick: (() -> uid = tab.uid; (e) -> onSelect(uid) if onSelect )(),
            tab.name
      )

      panels.push(
        React.createElement 'div',  
          key: "#{tab.uid}_panel",
          role: "tabpanel",
          className: "tab-pane #{"active" if activeTabUid==tab.uid}",
          id: tab.uid,
          tab.content
      )

    React.createElement 'div',   null,
      React.createElement 'ul',   className: "nav nav-tabs", role: "tablist", tabs
      React.createElement 'div',   className: "tab-content", panels

window.ReactTabs = ReactTabs