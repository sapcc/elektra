import React from "react"
import { Table } from "react-bootstrap"
import MembersTableItem from "./MembersTableItem"
import { Tooltip, OverlayTrigger } from "react-bootstrap"

const MembersTable = ({
  members,
  props,
  poolID,
  searchTerm,
  shouldPoll,
  isLoading,
  displayActions,
}) => {
  return (
    <Table className="table table-hover members" responsive>
      <thead>
        <tr>
          <th>
            <div className="display-flex">
              Name
              <div className="margin-left">
                <OverlayTrigger
                  placement="top"
                  overlay={
                    <Tooltip id="defalult-pool-tooltip">
                      Sorted by Name ASC
                    </Tooltip>
                  }
                >
                  <i className="fa fa-sort-asc" />
                </OverlayTrigger>
              </div>
              /ID
            </div>
          </th>
          <th>Status</th>
          <th style={{ width: "15%" }}>Tags</th>
          <th>IPs</th>
          <th style={{ width: "8%" }}>Weight</th>
          <th style={{ width: "8%" }}>Backup</th>
          <th>
            <span>Admin </span>
            <span>State Up</span>
          </th>
          {displayActions && <th className="snug"></th>}
        </tr>
      </thead>
      <tbody>
        {members && members.length > 0 ? (
          members.map((member, index) => (
            <MembersTableItem
              props={props}
              poolID={poolID}
              member={member}
              key={index}
              searchTerm={searchTerm}
              shouldPoll={shouldPoll}
              displayActions={displayActions}
            />
          ))
        ) : (
          <tr>
            <td colSpan="7">
              {isLoading ? <span className="spinner" /> : "No Members found."}
            </td>
          </tr>
        )}
      </tbody>
    </Table>
  )
}

export default MembersTable
