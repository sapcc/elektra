import React from "react"

//import { ContentAreaWrapper } from "juno-ui-components/build/ContentAreaWrapper"
//import { Panel } from "juno-ui-components/build/Panel"
//import { PanelBody } from "juno-ui-components/build/PanelBody"
// import { JsonViewer } from "juno-ui-components/build/JsonViewer"
// import { Tab } from "juno-ui-components/build/Tab"
// import { TabList } from "juno-ui-components/build/TabList"
// import { TabPanel } from "juno-ui-components/build/TabPanel"
// import { Tabs } from "juno-ui-components/build/Tabs"
// import { ContentAreaToolbar } from "juno-ui-components/build/ContentAreaToolbar"
// import { Button } from "juno-ui-components/build/Button"
// import { Spinner } from "juno-ui-components/build/Spinner"
// import { Icon } from "juno-ui-components"
// import { IntroBox } from "juno-ui-components/build/IntroBox"
// import { SearchInput } from "juno-ui-components/build/SearchInput"

import { apiClient } from "./lib/apiClient"

import {
  ContentAreaWrapper,
  Panel,
  PanelBody,
  JsonViewer,
  Tab,
  TabList,
  TabPanel,
  Tabs,
  ContentAreaToolbar,
  Button,
  Spinner,
  Icon,
  IntroBox,
  SearchInput,
} from "juno-ui-components"

import DeleteConfirm from "./DeleteConfirm"

export default function ProjectResourceCheck({ opened, onClose }) {
  // This state is used to store the data fetched from the API
  const [data, setData] = React.useState(null)
  // This state is used to store the loading state of the component
  const [loading, setLoading] = React.useState(false)
  // This is a ref to keep track of the mounted state of the component
  const mounted = React.useRef(true)
  // This state is used to store the search text entered by the user
  const [searchText, setSearchText] = React.useState("")

  // This is a memoized value that filters the data based on the search text
  const filteredData = React.useMemo(() => {
    if (!data) return []
    return data.filter((entry) => {
      if (!searchText) return true
      return (
        entry.resource?.name?.includes(searchText) ||
        entry.resource?.id?.includes(searchText) ||
        entry.type?.includes(searchText) ||
        entry.service_type?.includes(searchText)
      )
    })
  }, [data, searchText])

  const onConfirm = () => {
    console.log("Deleting project...")
    setLoading(true)
    apiClient
      .osApi("prodel")
      .delete(`/api/v1/projects/${window.scopedProjectId}`)
      .then(() => {
        setLoading(false)
        // after success
        var scopedDomainName = window.location.pathname.split("/")[1]
        var url =
          window.location.protocol +
          "//" +
          window.location.host +
          "/" +
          scopedDomainName
        window.location.href = url + "/home"
      })
      .catch((error) => {
        setLoading(false)
        console.error(error)
      })
      .finally(() => {
        setLoading(false)
      })
  }

  const fetchData = React.useCallback(() => {
    setLoading(true)
    apiClient
      .osApi("prodel")
      .get(`/api/v1/projects/${window.scopedProjectId}/resources/`)
      .then((response) => {
        if (!mounted.current) return
        setData(response.data?.resources)
        setLoading(false)
      })
      .catch((error) => {
        if (!mounted.current) return
        setData(null)
        setLoading(false)
        console.error(error)
      })
      .finally(() => {
        setLoading(false)
      })
  }, [])

  React.useEffect(() => {
    return () => {
      mounted.current = false
    }
  }, [])

  React.useEffect(() => {
    // If the panel is not opened, do not fetch data
    if (!opened) return
    fetchData()
  }, [fetchData, opened])

  const calculateResourceType = (resourceType, serviceType) => {
    let typeHref = undefined
    if (
      resourceType === "default_security_group_rules" ||
      resourceType === "security_groups"
    ) {
      typeHref = "/networking/widget/security-groups/"
    } else if (resourceType === "floating_ips") {
      typeHref = "/networking/floating_ips/"
    } else if (resourceType === "servers") {
      typeHref = "/compute/instances/"
    } else if (
      resourceType === "load_balancer_listeners" ||
      resourceType === "load_balancer_pools"
    ) {
      typeHref = "/lbaas2/?r=/loadbalancers"
    } else if (resourceType === "recordsets" || resourceType === "zones") {
      typeHref = "/dns-service/zones"
    } else if (resourceType === "volume_snapshots") {
      typeHref = "/block-storage/?r=/snapshots"
    } else if (resourceType === "volumes") {
      typeHref = "/image/ng?r=/os-images/volumes"
    } else if (resourceType === "keppel_accounts") {
      typeHref = "/keppel/#/accounts"
    } else if (resourceType === "manila_shares") {
      typeHref = "/shared-filesystem-storage/?r=/shares"
    } else if (resourceType === "manila_share_networks") {
      typeHref = "/shared-filesystem-storage/?r=/share-networks"
    } else if (resourceType === "manila_security_services") {
      typeHref = "/shared-filesystem-storage/?r=/security-services"
    } else if (resourceType === "manila_snapshots") {
      typeHref = "/shared-filesystem-storage/?r=/manila_snapshots"
    } else if (resourceType === "manila_replicas") {
      typeHref = "/shared-filesystem-storage/?r=/replicas"
    } else if (resourceType === "images") {
      typeHref = "/image/ng?r=/os-images/available"
    } else if (
      resourceType === "network_ports" ||
      resourceType === "routers" ||
      resourceType === "subnets" ||
      resourceType === "networks"
    ) {
      typeHref = "/networking/networks/external"
    } else if (resourceType === "object_store_containers") {
      typeHref = "/object-storage/containers"
    } else if (resourceType === "key_manager_containers") {
      typeHref = "/keymanagerng/containers"
    } else if (resourceType === "key_manager_secrets") {
      typeHref = "/keymanagerng/secrets"
    } else if (resourceType === "load_balancers") {
      typeHref = "/lbaas2/?r=/loadbalancers"
    }

    if (!typeHref) return <div className="tw-text-gray-400">n/a</div>
    typeHref = `/_/${window.scopedProjectId}${typeHref}`
    return (
      <Icon
        color="jn-global-text"
        icon="openInNew"
        href={typeHref}
        target="_blank"
        title={`Jump to ${serviceType}`}
      />
    )
  }

  const checkProjectCanNotBeDeleted = () => {
    //return false
    if (loading) return true
    if (!data) return false
    return true
  }

  return (
    <ContentAreaWrapper>
      <Panel
        className="tw-z-[1050]"
        heading="Delete Project Resources Check"
        onClose={onClose}
        opened={opened}
        size="large"
      >
        <PanelBody>
          <ContentAreaToolbar className="tw-space-x-2">
            <div className="tw-flex tw-w-full">
              <SearchInput
                onChange={(e) => setSearchText(e.target.value)}
                onClear={() => setSearchText("")}
                variant="default"
              />
            </div>
            {loading && <Spinner />}
            <Button disabled={loading} onClick={fetchData}>
              Refresh
            </Button>
            <DeleteConfirm
              onConfirm={() => {
                onConfirm()
              }}
              disabled={checkProjectCanNotBeDeleted()}
            />
          </ContentAreaToolbar>
          {data && !loading ? (
            <>
              {filteredData.length === 0 ? (
                <IntroBox text="No resources found. You can delete the Project." />
              ) : (
                <IntroBox text="You need to clean up the following resources before you can delete the Project. Follow the Link on the end of each line to jump to the related service." />
              )}
              <Tabs onSelect={function noRefCheck() {}}>
                <TabList>
                  <Tab>Styled Data</Tab>
                  <Tab>Raw Data</Tab>
                </TabList>
                <TabPanel>
                  <>
                    {filteredData.map((entry, index) => (
                      <div key={index}>
                        <table width="100%">
                          <tbody>
                            <tr>
                              <td width="45%">
                                {entry.resource?.name || entry.resource?.id}
                              </td>
                              <td width="30%">{entry?.type}</td>
                              <td width="20%">{entry?.service_type}</td>
                              <td width="5%">
                                {calculateResourceType(
                                  entry?.type,
                                  entry?.service_type
                                )}
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    ))}
                  </>
                </TabPanel>
                <TabPanel>
                  <JsonViewer
                    toolbar
                    theme="light"
                    data={{ data }}
                    showRoot={false}
                    expanded={10}
                  />
                </TabPanel>
              </Tabs>
            </>
          ) : (
            <p>Loading...</p>
          )}
        </PanelBody>
      </Panel>
    </ContentAreaWrapper>
  )
}
