import React from "react"
import { useHistory, useLocation } from "react-router-dom"
import {
  Tab,
  Tabs,
  TabPanel,
  TabList,
  Container
} from "juno-ui-components"

const TabsComponent = ({ tabsConfig, ...otherProps }) => {
  const location = useLocation()
  const history = useHistory()

  const [nav, content] = React.useMemo(() => {
    let tabItems = []
    let tabPanels = []
    for (let index in tabsConfig) {
      let tab = tabsConfig[index]
      let active = location.pathname.indexOf(tab.to) == 0
      let Component = tab.component

      // collect tab items
      tabItems.push(<Tab key={index}>{tab.label}</Tab>)
      // collect tab panels
      tabPanels.push(
        <TabPanel key={index}>
          <Container px={false}>
            <Component>{otherProps}</Component>
          </Container>
        </TabPanel>
      )
    }
    return [tabItems, tabPanels]
  }, [location, tabsConfig])

  return (
    <Tabs>
      <TabList>{nav}</TabList>

      {content}
    </Tabs>
  )
}

export default TabsComponent
