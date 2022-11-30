import moment from "moment"
import { Modal, Button } from "react-bootstrap"
import { Link } from "react-router-dom"
import React from "react"
import { Form } from "lib/elektra-form"
import { byteToHuman } from "lib/tools/size_formatter"

import { SEVERITY_ORDER } from "../../constants"
import Digest from "../digest"
import TagName from "../tagname"
import GCPolicyFolder from "./gc_policy_folder"
import VulnerabilityFolder from "./vulnerability_folder"

const hasVulnReport = (vulnStatus) => {
  return vulnStatus !== "Error" && vulnStatus !== "Unsupported"
}

const typeOfManifest = {
  "application/vnd.docker.distribution.manifest.v2+json": "image",
  "application/vnd.docker.distribution.manifest.list.v2+json": "list",
  "application/vnd.oci.image.manifest.v1+json": "image",
  "application/vnd.oci.image.index.v1+json": "list",
}

const formatStepCreatedBy = (input) => {
  //This attempts to reformat the "created_by" line of a image config history step into its respective Dockerfile command.
  let match

  //pattern #1: e.g. '/bin/sh -c #(nop) CMD ["/bin/sh"]'
  if ((match = /^\/bin\/sh -c #\(nop\) (.*)$/.exec(input)) !== null) {
    //strip everything until and including '#(nop)'
    return match[1]
  }

  //pattern #2: e.g. '/bin/sh -c apk update --no-cache'
  if ((match = /^\/bin\/sh -c (.*)$/.exec(input)) !== null) {
    //replace the "/bin/sh -c " with the original "RUN "
    return `RUN ${match[1]}`
  }

  //fallback: don't change anything
  return input
}

const getVulnerabilitiesForLayer = (digest, vulnReport) => {
  if (!vulnReport) {
    return []
  }

  const vulnsBySeverity = {}
  //for each package introduced in this layer...
  for (const packageID in vulnReport.environments) {
    if (
      vulnReport.environments[packageID].some(
        (env) => env.introduced_in == digest
      )
    ) {
      //collect each vulnerability affecting that package
      for (const vulnID of vulnReport.package_vulnerabilities[packageID] ||
        []) {
        //...add a <tr> for that vulnerability
        const pkg = vulnReport.packages[packageID]
        const vuln = vulnReport.vulnerabilities[vulnID]
        const severity = vuln.normalized_severity

        vulnsBySeverity[severity] = vulnsBySeverity[severity] || []
        vulnsBySeverity[severity].push({ ...vuln, pkg })
      }
    }
  }

  const folders = []
  for (const severity in vulnsBySeverity) {
    const vulns = vulnsBySeverity[severity]
    folders.push([
      SEVERITY_ORDER[severity] || 0,
      <VulnerabilityFolder severity={severity} vulns={vulns} />,
    ])
  }

  //`folders` contains pairs of [numerical_severity, folder] -> sort on severity in descending order
  folders.sort((a, b) => b[0] - a[0])
  return folders.map((pair) => pair[1])
}

export default class ImageDetailsModal extends React.Component {
  state = {
    show: true,
  }

  close = (e) => {
    if (e) {
      e.stopPropagation()
    }
    this.setState({ ...this.state, show: false })
    setTimeout(
      () =>
        this.props.history.replace(
          `/repo/${this.props.account.name}/${this.props.repository.name}`
        ),
      300
    )
  }

  componentDidMount() {
    this.loadData()
  }
  componentDidUpdate() {
    this.loadData()
  }
  loadData() {
    const { name: accountName } = this.props.account || {}
    const { name: repoName } = this.props.repository || {}
    if (accountName && repoName) {
      this.props.loadManifestsOnce()
      this.props.loadManifestOnce()
      const { data: manifest } = this.props.manifest || {}
      if (manifest && manifest.config) {
        this.props.loadBlobOnce(manifest.config.digest)
        if ((this.props.manifests.data || []).length > 0) {
          const { digest } = this.props.match.params
          const manifestInfo = this.props.manifests.data.find(
            (m) => m.digest == digest
          )
          if (
            manifestInfo &&
            hasVulnReport(manifestInfo.vulnerability_status)
          ) {
            this.props.loadVulnsOnce()
          }
        }
      }
    }
  }

  render() {
    //className='keppel' on <Modal> ensures that CSS rules from this plugin can apply
    return (
      <Modal
        backdrop="static"
        dialogClassName="modal-xl"
        className="keppel"
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Image details</Modal.Title>
        </Modal.Header>
        <Modal.Body>{this.renderModalBody()}</Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }

  renderModalBody() {
    const { isFetching: isFetchingManifests, data: manifests } =
      this.props.manifests
    if (isFetchingManifests || manifests === undefined) {
      return (
        <p>
          <span className="spinner" /> Loading image list...
        </p>
      )
    }
    const { isFetching: isFetchingManifest, data: manifest } =
      this.props.manifest
    if (isFetchingManifest || manifest === undefined) {
      return (
        <p>
          <span className="spinner" /> Loading image manifest...
        </p>
      )
    }

    const { digest } = this.props.match.params
    const {
      media_type: mediaType,
      tags,
      vulnerability_status: vulnStatus,
      vulnerability_scan_error: vulnScanError,
      gc_status: gcStatus,
    } = manifests.find((m) => m.digest == digest) || {}

    const { isFetching: isFetchingImageConfig, data: imageConfig } =
      this.props.imageConfig || {}
    if (
      typeOfManifest[mediaType] == "image" &&
      (isFetchingImageConfig || imageConfig === undefined)
    ) {
      return (
        <p>
          <span className="spinner" /> Loading image config...
        </p>
      )
    }
    const { isFetching: isFetchingVulnReport, data: vulnReport } =
      this.props.vulnReport || {}
    if (
      typeOfManifest[mediaType] == "image" &&
      hasVulnReport(vulnStatus) &&
      (isFetchingVulnReport || vulnReport === undefined)
    ) {
      return (
        <p>
          <span className="spinner" /> Loading vulnerability report...
        </p>
      )
    }

    const repositoryURL = `${this.props.dockerInfo.registryDomain}/${this.props.account.name}/${this.props.repository.name}`

    const tagsDisplay = []
    for (const [tag, idx] of (tags || []).map((tag, idx) => [tag, idx])) {
      if (idx > 0) {
        tagsDisplay.push(", ")
      }
      tagsDisplay.push(
        <TagName key={tag.name} name={tag.name} repositoryURL={repositoryURL} />
      )
    }

    return (
      <table className="table datatable">
        <tbody>
          <tr>
            <th className="preset-width">Canonical digest</th>
            <td colSpan="2">
              <Digest
                digest={digest}
                wideDisplay={true}
                repositoryURL={repositoryURL}
              />
            </td>
          </tr>
          {tags && tags.length > 0 ? (
            <tr>
              <th>Tagged as</th>
              <td colSpan="2">{tagsDisplay}</td>
            </tr>
          ) : null}
          <tr>
            <th>MIME type</th>
            <td colSpan="2">{mediaType}</td>
          </tr>
          {gcStatus ? this.renderGCStatus(gcStatus, repositoryURL) : null}
          {typeOfManifest[mediaType] == "list"
            ? this.renderSubmanifestReferences(
                manifest.manifests,
                manifests,
                repositoryURL
              )
            : null}
          {typeOfManifest[mediaType] == "image"
            ? this.renderLayers(
                manifest,
                imageConfig,
                vulnReport,
                vulnStatus,
                vulnScanError,
                repositoryURL
              )
            : null}
        </tbody>
      </table>
    )
  }

  renderGCStatus(gcStatus, repositoryURL) {
    if (gcStatus.protected_by_recent_upload) {
      return (
        <GCPolicyFolder caption="Protected from garbage collection because of recent upload" />
      )
    }

    if (gcStatus.protected_by_parent) {
      const digest = gcStatus.protected_by_parent
      const caption = (
        <React.Fragment>
          {"Protected from garbage collection because of reference in "}
          <Digest digest={digest} repositoryURL={repositoryURL} />
          {" ("}
          <Link
            to={`/repo/${this.props.account.name}/${this.props.repository.name}/-/manifest/${digest}/details`}
          >
            Details
          </Link>
          {")"}
        </React.Fragment>
      )
      return <GCPolicyFolder caption={caption} />
    }

    if (gcStatus.protected_by_policy) {
      return (
        <GCPolicyFolder
          caption="Protected from garbage collection by policy"
          policies={[gcStatus.protected_by_policy]}
        />
      )
    }

    if (gcStatus.relevant_policies) {
      const policies = gcStatus.relevant_policies
      if (gcStatus.relevant_policies.length === 0) {
        return <GCPolicyFolder caption="No matching policies" />
      }
      return (
        <GCPolicyFolder
          caption={`${policies.length} matching policies`}
          policies={policies}
        />
      )
    }

    return <GCPolicyFolder caption="Unknown" />
  }

  renderSubmanifestReferences(submanifests, allManifests, repositoryURL) {
    const rows = []
    let rowIndex = 0
    for (const manifest of submanifests) {
      rowIndex++
      const manifestInfo = allManifests.find((m) => m.digest == manifest.digest)
      const detailsLink = (
        <Link
          to={`/repo/${this.props.account.name}/${this.props.repository.name}/-/manifest/${manifest.digest}/details`}
        >
          Details
        </Link>
      )

      rows.push(
        <tr key={`spacer-${manifest.digest}`} className="spacer">
          <td />
        </tr>
      )

      rows.push(
        <tr key={`digest-${manifest.digest}`}>
          <th rowSpan={manifestInfo ? 4 : 3}>Payload #{rowIndex}</th>
          <td colSpan="2">
            <Digest
              digest={manifest.digest}
              wideDisplay={true}
              repositoryURL={repositoryURL}
            />
          </td>
        </tr>
      )

      rows.push(
        <tr key={`status-${manifest.digest}`}>
          <th>Status</th>
          <td>
            {manifestInfo ? (
              <React.Fragment>Available ({detailsLink})</React.Fragment>
            ) : (
              "Not available"
            )}
          </td>
        </tr>
      )

      if (manifestInfo) {
        rows.push(
          <tr key={`vulnstatus-${manifest.digest}`}>
            <th>Vulnerability status</th>
            <td>
              {manifestInfo.vulnerability_status} ({detailsLink})
            </td>
          </tr>
        )
      }

      rows.push(
        <tr key={`platform-${manifest.digest}`}>
          <th>Platform</th>
          <td>
            <code>{JSON.stringify(manifest.platform)}</code>
          </td>
        </tr>
      )
    }

    return rows
  }

  renderLayers(manifest, imageConfig, vulnReport, vulnStatus, vulnScanError) {
    if (!imageConfig) {
      return (
        <tr className="text-danger">
          <th>Error</th>
          <td>Cannot load image configuration.</td>
        </tr>
      )
    }
    if (hasVulnReport(vulnStatus) && !vulnReport) {
      return (
        <tr className="text-danger">
          <th>Error</th>
          <td>Cannot load vulnerability report.</td>
        </tr>
      )
    }

    const rows = []
    if (!hasVulnReport(vulnStatus)) {
      rows.push(
        <tr className="text-danger">
          <th>Vulnerability scan error</th>
          <td>{vulnScanError}</td>
        </tr>
      )
    }

    let stepIndex = 0
    let layerIndex = 0
    for (const step of imageConfig.history || []) {
      stepIndex++
      const layer = step.empty_layer ? null : manifest.layers[layerIndex++]
      const vulnRows = layer
        ? getVulnerabilitiesForLayer(layer.digest, vulnReport)
        : null

      rows.push(
        <tr key={`spacer-${stepIndex}`} className="spacer">
          <td />
        </tr>
      )

      rows.push(
        <tr key={`step-${stepIndex}`}>
          <th rowSpan={layer ? 3 : 2}>Step #{stepIndex}</th>
          <td colSpan="2">
            <code>{formatStepCreatedBy(step.created_by)}</code>
          </td>
        </tr>
      )

      const createdAt = moment(step.created) //`step.created` is in ISO8601 format, e.g. "2020-10-22T02:19:24.33416307Z"
      rows.push(
        <tr key={`created-${stepIndex}`}>
          <th>Built</th>
          <td>
            <span title={createdAt.format("LLLL")}>
              {createdAt.fromNow(true)} ago
            </span>
          </td>
        </tr>
      )

      //NOTE: `repositoryURL` is not given to <Digest /> because the generated
      //URLs would be nonsensical (the `<repo>@<digest>` format only makes
      //sense for manifests)
      if (layer) {
        rows.push(
          <tr key={`layer-${stepIndex}`}>
            <th>Layer size</th>
            <td>
              {byteToHuman(layer.size)} at <Digest digest={layer.digest} />
            </td>
          </tr>
        )
        Array.prototype.push.apply(rows, vulnRows)
      }
    }

    return rows
  }
}
