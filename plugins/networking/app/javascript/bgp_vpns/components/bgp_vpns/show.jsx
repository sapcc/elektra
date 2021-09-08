import React from "react"
import { Modal, Button, Tabs, Tab } from "react-bootstrap"
import { useHistory, useParams } from "react-router-dom"
import { useGlobalState } from "../../stateProvider"
import BgpVpnRouters from "./bgpvpnRouters"

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
  const { id } = useParams()
  const { bgpvpns, projects: cachedProjects } = useGlobalState()

  const item = React.useMemo(() => {
    if (!id) return
    return bgpvpns.items.find((i) => i.id === id)
  }, [bgpvpns.items, id])

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
          BGP VPN {item?.name}
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        {bgpvpns.isFetching ? (
          <span>
            <span className="spinner" />
            Loading...
          </span>
        ) : !item ? (
          <span>Could not find BGP VPN {id}</span>
        ) : (
          <Tabs defaultActiveKey={1} id="routers" mountOnEnter={true}>
            <Tab eventKey={1} title="Overview">
              <table className="table">
                <tbody>
                  <Row label="ID" value={item.id} />
                  <Row label="Name" value={item.name} />
                  <Row label="Project">
                    {cachedProjects.data[item.project_id] ? (
                      <React.Fragment>
                        <a href={`/_/${item.project_id}`} target="_blank">
                          {
                            cachedProjects.data[item.project_id].payload?.scope
                              ?.domain_name
                          }
                          /{cachedProjects.data[item.project_id].name}
                        </a>
                        <br />
                        <span className="info-text">{item.project_id}</span>
                      </React.Fragment>
                    ) : (
                      item.project_id
                    )}
                  </Row>
                  <Row label="Shared" value={`${item.shared}`} />
                  <Row label="Type" value={item.type} />
                  <Row label="Import Targets" value={item.import_targets} />
                  <Row label="Export Targets" value={item.export_targets} />
                </tbody>
              </table>
            </Tab>
            <Tab eventKey={2} title="Routers">
              <BgpVpnRouters bgpvpn={item} />
            </Tab>
          </Tabs>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Close</Button>
      </Modal.Footer>
    </Modal>
  )
}

export default Show
