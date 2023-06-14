import React, { useState } from "react"

import { DataTable } from "lib/components/datatable"

import { SEVERITY_ORDER, TRIVY_TO_KEPPEL_SEVERITY } from "../../constants"

const columns = [
  {
    key: "object",
    label: "Affected package/object/file",
    sortStrategy: "text",
    searchKey: (props) => `${props.data.object} ${props.data.objectDescription || ""} ${props.data.description || ""}`,
    sortKey:   (props) => `${props.data.object} ${props.data.objectDescription || ""}`,
  },
  { key: "title", label: "Title" },
  {
    key: "severity",
    label: "Severity",
    sortStrategy: "numeric",
    searchKey: (props) => props.data.severity,
    sortKey:   (props) => SEVERITY_ORDER[props.data.severity] || 0,
  },
  //TODO: If sorting for the version columns is desired, a library for version comparisons should be imported.
  {
    key: "installed_version",
    label: "Installed version",
    searchKey: (props) => props.data.installedVersion,
  },
  {
    key: "fixed_version",
    label: "Fixed in version",
    searchKey: (props) => props.data.fixedVersion,
  },
];

const VulnerabilityRow = ({ data }) => {
  const [isOpen, setOpen] = useState(false);

  return (
    <>
      <tr>
        <td className="col-md-3">
          <div>{data.object}</div>
          {data.objectDescription ? (
            <div className="small text-muted">{data.objectDescription}</div>
          ) : null}
        </td>
        <td className="col-md-4">
          <div>
            {data.primaryURL ? (
              <a href={data.primaryURL} target="_blank">{data.vulnerabilityID}</a>
            ) : data.vulnerabilityID}
          </div>
          <div className="small text-muted">{data.title}</div>
        </td>
        <td className="col-md-1">{data.severity}</td>
        <td className="col-md-2">{data.installedVersion}</td>
        <td className="col-md-2">{data.fixedVersion || <span className="text-muted">N/A</span>}</td>
      </tr>
      <tr className="explains-previous-line">
        <td colSpan="5">
          {data.description
            ? <p className={isOpen ? "vuln-desc" : "vuln-desc vuln-desc-folded"}>{data.description}</p>
            : null}
          {isOpen
            ? <pre><code>{JSON.stringify(data.raw, null, 2)}</code></pre>
            : null}
          <div>
            <i className={`fa fa-fw fa-caret-${isOpen ? "up" : "right"}`} />
            <a role="button" onClick={() => { setOpen(!isOpen); return false }}>{isOpen ? "Show less" : "Show more"}</a>
          </div>
        </td>
      </tr>
    </>
  );
};

//NOTE: `vulnReport` is the JSON that falls out of `trivy image --scanners vuln ${IMAGE_REF}`,
//plus Keppel-specific enrichment in the "X-Keppel-..." fields.
export const VulnerabilityTable = ({ vulnReport }) => {
  const [searchText, setSearchText] = useState("");

  //compile a preprocessed list of problems (the pre-processing is
  //necessary because we have two types of problems in this table)
  const rows = [];

  //type 1: generate one problem if the OS is EOSL, to explain the
  //vulnerability status "Rotten"
  const osInfo = vulnReport.Metadata.OS || {};
  if (osInfo.EOSL) {
    rows.push({
      //column 1
      object: osInfo.Family, // e.g. "alpine"
      objectDescription: "Base image",
      //column 2
      title: "End of Support Life",
      vulnerabilityID: "EOSL",
      primaryURL: null,
      //column 3
      severity: "Rotten",
      //column 4
      installedVersion: osInfo.Name, // e.g. "3.14.1"
      //column 5
      fixedVersion: null,
      //secondary row
      description: `The base image has reached End of Support Life and will not receive further security updates. Please consider updating to a supported version of ${osInfo.Family} as soon as possible.`,
      raw: osInfo,
    });
  }

  //type 2: generate one problem per vulnerability
  //TODO: X-Keppel-Applicable-Policies
  for (const section of (vulnReport.Results || [])) {
    for (const vuln of (section.Vulnerabilities || [])) {
      const severity = vuln.Severity || "UNKNOWN";
      // NOTE: `|| null` is for fields that can legitimately be empty.
      const row = {
        //column 1
        object: vuln.PkgName || "Unknown package",
        objectDescription: vuln.PkgPath || null,
        //column 2
        title: vuln.Title || "No title",
        vulnerabilityID: vuln.VulnerabilityID || "Unknown ID",
        primaryURL: vuln.PrimaryURL || null,
        //column 3
        severity: TRIVY_TO_KEPPEL_SEVERITY[severity] || severity,
        //column 4
        installedVersion: vuln.InstalledVersion || "Unknown version",
        //column 5
        fixedVersion: vuln.FixedVersion || null,
        //secondary row
        description: vuln.Description || null,
        raw: vuln,
      };
      if (section.Class !== "os-pkgs" && row.objectDescription === null) {
        row.objectDescription = `Found in ${section.Target}`;
      }
      rows.push(row);
    }
  }

  return (
    <>
      <div className="search-box">
        <input
          className="form-control"
          type="text"
          value={searchText}
          placeholder="Filter vulnerabilities"
          onChange={(e) => setSearchText(e.target.value)}
        />
      </div>
      <DataTable columns={columns} pageSize={6} searchText={searchText}>
        {rows.map((data, idx) => <VulnerabilityRow key={idx} data={data} />)}
      </DataTable>
    </>
  );
}
