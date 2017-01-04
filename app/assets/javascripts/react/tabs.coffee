{div,h4,a,ul,li} = React.DOM

@ReactTabs = ({tabsConfig, activeTabUid, onSelect}) ->
  return null unless tabsConfig and tabsConfig.length

  if tabsConfig.length==1
    div null,
      tabsConfig[0].content
  else
    activeTabUid ||= tabsConfig[0].uid
    tabs = []
    panels = []
    for tab in tabsConfig
      tabs.push(
        li
          key: "#{tab.uid}_tab",
          role: "presentation",
          className: ("active" if activeTabUid==tab.uid),
          a
            href: "##{tab.uid}",
            "aria-controls": "home",
            role: "tab",
            "data-toggle": "tab",
            onClick: (() -> uid = tab.uid; (e) -> onSelect(uid) if onSelect )(),
            tab.name
      )

      panels.push(
        div
          key: "#{tab.uid}_panel",
          role: "tabpanel",
          className: "tab-pane #{"active" if activeTabUid==tab.uid}",
          id: tab.uid,
          tab.content
      )

    div null,
      ul className: "nav nav-tabs", role: "tablist", tabs
      div className: "tab-content", panels
