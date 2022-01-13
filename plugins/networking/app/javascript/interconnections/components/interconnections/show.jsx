import React from "react"
import { Modal, Button, Tabs, Tab } from "react-bootstrap"
import { useHistory, useParams } from "react-router-dom"
import { useGlobalState } from "../../stateProvider"

const Row = ({ label, value, children }) => {
  label = (label && label.replace("_", " ")) || ""
  return (
    <tr>
      <th style={{ width: "30%" }}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
}

const Show = () => {
  const [show, setShow] = React.useState(true)
  const history = useHistory()
  const { id, tab } = useParams()
  const {
    interconnections,
    cachedProjects,
    cachedInterconnections,
    cachedBgpVpns,
  } = useGlobalState()
  const cachedProjectsData = React.useMemo(
    () => cachedProjects.data || {},
    [cachedProjects.data]
  )
  const cachedInterconnectionsData = React.useMemo(
    () => cachedInterconnections.data || {},
    [cachedInterconnections.data]
  )
  const cachedBgpVpnsData = React.useMemo(
    () => cachedBgpVpns.data || {},
    [cachedBgpVpns.data]
  )

  const item = React.useMemo(() => {
    if (!id || interconnections.isFetching || !interconnections.items) return
    return interconnections.items.find((i) => i.id === id)
  }, [interconnections.items, id])

  const close = React.useCallback((e) => {
    setShow(false)
  }, [])

  const back = React.useCallback((e) => {
    history.replace("/")
  }, [])

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Interconnection {item?.name}
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        {interconnections.isFetching ? (
          <span>
            <span className="spinner" />
            Loading...
          </span>
        ) : !item ? (
          <span>Could not find interconnection {id}</span>
        ) : (
          <table className="table">
            <tbody>
              {/* 
		"local_parameters": {
			"project_id": ["69522a037705457f9dc686675929617d"]
		},
		"remote_parameters": {
			"project_id": ["69522a037705457f9dc686675929617d"]
		} */}
              <Row label="ID" value={item.id} />
              <Row label="Name" value={item.name} />
              <Row label="Project">
                {cachedProjectsData[item.project_id] ? (
                  <React.Fragment>
                    <a href={`/_/${item.project_id}`} target="_blank">
                      {
                        cachedProjectsData[item.project_id].payload?.scope
                          ?.domain_name
                      }
                      /{cachedProjectsData[item.project_id].name}
                    </a>
                    <br />
                    <span className="info-text">{item.project_id}</span>
                  </React.Fragment>
                ) : (
                  item.project_id
                )}
              </Row>
              <Row label="Type" value={item.type} />
              <Row label="Local BGP VPN">
                {cachedBgpVpnsData[item.local_resource_id] ? (
                  <React.Fragment>
                    {cachedBgpVpnsData[item.local_resource_id].name}
                    <br />
                    <span className="info-text">{item.local_resource_id}</span>
                  </React.Fragment>
                ) : (
                  item.local_resource_id
                )}
              </Row>
              <Row label="Remote BGP VPN">
                {cachedBgpVpnsData[item.remote_resource_id] ? (
                  <React.Fragment>
                    {cachedBgpVpnsData[item.remote_resource_id].name}
                    <br />
                    <span className="info-text">{item.remote_resource_id}</span>
                  </React.Fragment>
                ) : (
                  item.remote_resource_id
                )}
              </Row>
              <Row label="Remote Region" value={item.remote_region} />
              <Row label="Remote Interconnection">
                {cachedInterconnectionsData[item.remote_interconnection_id] ? (
                  <React.Fragment>
                    {
                      cachedInterconnectionsData[item.remote_interconnection_id]
                        .name
                    }
                    <br />
                    <span className="info-text">
                      {item.remote_interconnection_id}
                    </span>
                  </React.Fragment>
                ) : (
                  item.remote_interconnection_id
                )}
              </Row>
              <Row label="State" value={item.state} />
            </tbody>
          </table>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Close</Button>
      </Modal.Footer>
    </Modal>
  )
}

export default Show
