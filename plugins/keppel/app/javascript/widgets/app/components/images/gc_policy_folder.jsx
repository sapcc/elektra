import { useState } from "react"
import React from "react"

const actionStrings = { protect: "Protect", delete: "Delete" }
const timeFieldStrings = { pushed_at: "push", last_pulled_at: "last pull" }
const timeUnitStrings = {
  s: "seconds",
  m: "minutes",
  h: "hours",
  d: "days",
  w: "weeks",
  y: "years",
}

const GCPolicyFolder = ({ caption, policies }) => {
  if (!policies || policies.length === 0) {
    return (
      <tr>
        <th>Result of last GC</th>
        <td colSpan="2">{caption}</td>
      </tr>
    )
  }

  const [isOpen, setOpen] = useState(false)

  const rows = []
  if (isOpen) {
    for (const policy of policies) {
      const rx = (attr) => policy[attr] || ""
      const tc = policy.time_constraint || {}
      rows.push(
        <tr key={rows.length}>
          <td colSpan="2" className="gcpolicy">
            <strong>{actionStrings[policy.action] || policy.action}</strong>
            {" image "}
            {rx("match_repository") != ".*" && (
              <>
                <strong>only if</strong>
                {" in repository "}
                <code>{rx("match_repository")}</code>{" "}
              </>
            )}
            {rx("except_repository") != "" && (
              <>
                <strong>except if</strong>
                {" in repository "}
                <code>{rx("except_repository")}</code>{" "}
              </>
            )}
            {rx("match_tag") != "" && (
              <>
                <strong>only if</strong>
                {" tagged as "}
                <code>{rx("match_tag")}</code>{" "}
              </>
            )}
            {rx("except_tag") != "" && (
              <>
                <strong>except if</strong>
                {" tagged as "}
                <code>{rx("except_tag")}</code>{" "}
              </>
            )}
            {policy.only_untagged && (
              <>
                <strong>only if</strong>
                {" image does not have tags "}
              </>
            )}
            {tc.on && (
              <>
                <strong>only if</strong>
                {` ${timeFieldStrings[tc.on] || tc.on} timestamp of image `}
                {tc.older_than &&
                  `is older than ${tc.older_than.value} ${
                    timeUnitStrings[tc.older_than.unit] || tc.older_than.unit
                  }`}
                {tc.newer_than &&
                  `is newer than ${tc.newer_than.value} ${
                    timeUnitStrings[tc.newer_than.unit] || tc.newer_than.unit
                  }`}
                {tc.oldest &&
                  `is among the oldest ${tc.oldest} in this repository`}
                {tc.newest &&
                  `is among the newest ${tc.newest} in this repository`}
              </>
            )}
          </td>
        </tr>
      )
    }
  }

  return (
    <>
      <tr>
        <th rowSpan={1 + rows.length}>Result of last GC</th>
        <td
          colSpan="2"
          className="gcpolicy-folder"
          onClick={() => setOpen(!isOpen)}
        >
          <i className={`fa fa-fw fa-caret-${isOpen ? "down" : "right"}`} />
          {` ${caption}`}
        </td>
      </tr>
      {rows}
    </>
  )
}

export default GCPolicyFolder
