import { useEffect, useState } from "react"
import StaticTags from "../StaticTags"
import useHealthMonitor from "../../lib/hooks/useHealthMonitor"
import CopyPastePopover from "../shared/CopyPastePopover"
import Log from "../shared/logger"
import HelpPopover from "../shared/HelpPopover"
import useStatus from "../../lib/hooks/useStatus"
import usePolling from "../../lib/hooks/usePolling"

const HealthmonitorDetails = ({ loadbalancerID, poolID, healthmonitor }) => {
  const {
    pollHealthmonitor,
    httpMethodRelation,
    expectedCodesRelation,
    urlPathRelation,
  } = useHealthMonitor()
  const { entityStatus } = useStatus(
    healthmonitor.operating_status,
    healthmonitor.provisioning_status
  )

  const pollingCallback = () => {
    return pollHealthmonitor(loadbalancerID, poolID, healthmonitor.id, null)
  }

  usePolling({
    delay: healthmonitor.provisioning_status.includes("PENDING")
      ? 20000
      : 60000,
    callback: pollingCallback,
    active: true,
  })

  const displayName = () => {
    if (healthmonitor.name) {
      return healthmonitor.name
    } else {
      return <CopyPastePopover text={healthmonitor.id} shouldPopover={false} />
    }
  }

  const displayID = () => {
    if (healthmonitor.name) {
      return (
        <small className="info-text">
          <CopyPastePopover
            text={healthmonitor.id}
            shouldPopover={false}
            bsClass="cp copy-paste-ids"
          />
        </small>
      )
    }
  }

  return (
    <div className="list multiple-subtable-scroll-body">
      <div className="list-entry">
        <div className="row">
          <div className="col-md-12">
            <b>Name/ID:</b>
          </div>
        </div>

        <div className="row">
          <div className="col-md-12">{displayName()}</div>
        </div>

        {healthmonitor.name && (
          <div className="row">
            <div className="col-md-12 text-nowrap">{displayID()}</div>
          </div>
        )}
      </div>

      <div className="list-entry">
        <div className="row">
          <div className="col-md-12">
            <b>Status:</b>
          </div>
        </div>

        <div className="row">
          <div className="col-md-12">
            <div>{entityStatus}</div>
          </div>
        </div>
      </div>

      <div className="list-entry">
        <div className="row">
          <div className="col-md-12">
            <b>Tags:</b>
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">
            <StaticTags tags={healthmonitor.tags} />
          </div>
        </div>
      </div>

      <div className="list-entry">
        <div className="row">
          <div className="col-md-12">
            <b>Type:</b>
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">{healthmonitor.type}</div>
        </div>
      </div>

      <div className="list-entry">
        <div className="row">
          <div className="col-md-12">
            <b>Retries/Probe Timeout/Interval:</b>
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">
            {healthmonitor.max_retries} / {healthmonitor.timeout} /{" "}
            {healthmonitor.delay}
          </div>
        </div>
      </div>

      {httpMethodRelation(healthmonitor.type) && (
        <div className="list-entry">
          <div className="row">
            <div className="col-md-12">
              <b>HTTP Method:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">{healthmonitor.http_method}</div>
          </div>
        </div>
      )}

      {expectedCodesRelation(healthmonitor.type) && (
        <div className="list-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Expected Codes:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">{healthmonitor.expected_codes}</div>
          </div>
        </div>
      )}

      {urlPathRelation(healthmonitor.type) && (
        <div className="list-entry">
          <div className="row">
            <div className="col-md-12">
              <b>URL Path:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <CopyPastePopover text={healthmonitor.url_path} size={40} />
            </div>
          </div>
        </div>
      )}

      <div className="list-entry">
        <div className="row">
          <div className="col-md-12 display-flex">
            <b>Healthmonitor IPs:</b>
            <HelpPopover text="These IP addresses should be reachable for the health check monitors." />
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">
            <ul className="less-left-margin">
              {healthmonitor.allowed_address_pairs &&
                healthmonitor.allowed_address_pairs.length > 0 &&
                healthmonitor.allowed_address_pairs.map((pair_item, index) => (
                  <li key={index}>
                    <CopyPastePopover
                      text={pair_item.ip_address}
                      shouldPopover={false}
                    />
                    <small className="info-text">
                      MAC address: {pair_item.mac_address}
                    </small>
                  </li>
                ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export default HealthmonitorDetails
