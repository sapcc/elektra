import React from "react"
import { DropdownButton, MenuItem, ButtonGroup } from "react-bootstrap"

const AddRouterAssociation = ({ routers, onSelect, disabled, routerID }) => {
  const selected = React.useMemo(
    () => routers.find((r) => r.id === routerID),
    [routerID]
  )

  return (
    <ButtonGroup bsSize="small">
      <DropdownButton
        disabled={disabled}
        title={selected?.name || "Select a router"}
        id="add-router"
        bsSize="small"
        onSelect={onSelect}
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
    </ButtonGroup>
  )
}

export default AddRouterAssociation
