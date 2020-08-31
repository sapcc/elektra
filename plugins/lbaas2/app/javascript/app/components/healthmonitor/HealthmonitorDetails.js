import { useEffect, useState } from "react"
import StateLabel from "../shared/StateLabel"
import StatusLabel from "../shared/StatusLabel"
import StaticTags from "../StaticTags"
import useHealthMonitor from "../../../lib/hooks/useHealthMonitor"
import CopyPastePopover from "../shared/CopyPastePopover"
import Log from "../shared/logger"

const HealthmonitorDetails = ({ loadbalancerID, poolID, healthmonitor }) => {
  const {
    pollHealthmonitor,
    httpMethodRelation,
    expectedCodesRelation,
    urlPathRelation,
  } = useHealthMonitor()
  let polling = null

  useEffect(() => {
    if (healthmonitor.provisioning_status.includes("PENDING")) {
      startPolling(5000)
    } else {
      startPolling(30000)
    }

    return function cleanup() {
      stopPolling()
    }
  })

  const startPolling = (interval) => {
    // do not create a new polling interval if already polling
    if (polling) return
    polling = setInterval(() => {
      Log.debug(
        "Polling healthmonitor -->",
        healthmonitor.id,
        " with interval -->",
        interval
      )
      pollHealthmonitor(loadbalancerID, poolID, healthmonitor.id, null)
        .then((data) => {})
        .catch((error) => {})
    }, interval)
  }

  const stopPolling = () => {
    Log.debug("stop polling for healthmonitor id -->", healthmonitor.id)
    clearInterval(polling)
    polling = null
  }

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
        <span className="info-text">
          <CopyPastePopover
            text={healthmonitor.id}
            shouldPopover={false}
            bsClass="cp copy-paste-ids"
          />
        </span>
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
            <b>State/Provisioning Status:</b>
          </div>
        </div>

        <div className="row">
          <div className="col-md-12">
            <div className="display-flex">
              <span>
                <StateLabel label={healthmonitor.operating_status} />
              </span>
              <span className="label-right">
                <StatusLabel label={healthmonitor.provisioning_status} />
              </span>
            </div>
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
            <b>Retries/Timeout/Delay:</b>
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
            <div className="col-md-12">{healthmonitor.url_path}</div>
          </div>
        </div>
      )}
    </div>
  )
}

export default HealthmonitorDetails
