import React from "react"
import { DropdownButton, MenuItem, ButtonGroup, Button } from "react-bootstrap"

const AddRouterAssociation = ({ routers, onSelect }) => {
  const [routerID, setRouterID] = React.useState()
  const selected = React.useMemo(
    () => routers.find((r) => r.id === routerID),
    [routerID]
  )

  return (
    <ButtonGroup bsSize="small">
      <DropdownButton
        title={selected?.name || "Select a router"}
        id="add-router"
        bsSize="small"
        onSelect={(routerID) => setRouterID(routerID)}
      >
        {routers.map((router, i) => (
          <MenuItem key={i} eventKey={router.id}>
            <div>{router.name}</div>
            {router.subnets && (
              <div className="info-text">
                {(router.subnets || []).map((s, j) => (
                  <React.Fragment key={j}>
                    {s.name} {s.cidr}
                    <br />
                  </React.Fragment>
                ))}
              </div>
            )}
          </MenuItem>
        ))}
      </DropdownButton>
      <Button bsStyle="primary" onClick={() => onSelect(routerID)}>
        Add
      </Button>
    </ButtonGroup>
  )
}

export default AddRouterAssociation
