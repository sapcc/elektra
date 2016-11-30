{div,h4,a,ul,li} = React.DOM
   
shared_filesystem_storage.ReactTabs = React.createClass
  render: ->
    return null if Object.keys(@props.tabs).length<=0
    
    if Object.keys(@props.tabs).length==1
      div null,
        @props.tabs[Object.keys(@props.tabs)[0]] 
    else   
      
      activeTab = @props.activeTab || Object.keys(@props.tabs)[0]

      tabs = []
      panels = []
      for tab,content of @props.tabs
        tabId = tab.replace(/\s/g,'-').toLowerCase()

        tabs.push(li key: "#{tabId}_tab", role: "presentation", className: ("active" if activeTab==tab),
          a href: "##{tabId}", "aria-controls": "home", role: "tab",  "data-toggle": "tab", tab)
        panels.push(div key: "#{tabId}_panel", role: "tabpanel", className: "tab-pane #{"active" if activeTab==tab}", id: tabId, content)
    
      div null,      
        ul className: "nav nav-tabs", role: "tablist", tabs
        div className: "tab-content", panels    
    


