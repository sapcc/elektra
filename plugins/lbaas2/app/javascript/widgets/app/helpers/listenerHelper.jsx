import React from "react"

export const listenerProtocolTypes = () => {
  return [
    { label: "HTTP", value: "HTTP" },
    // Disable HTTPS when creating listeners
    // With Octavia, HTTPS is exactly the same as TCP (it’s been meant to be TLS-HTTP passthrough for the backends, but octavia doesn’t really handles them any different than TCP).
    { label: "HTTPS", value: "HTTPS", state: "disabled" },
    { label: "TCP", value: "TCP" },
    { label: "TERMINATED_HTTPS", value: "TERMINATED_HTTPS" },
    { label: "UDP", value: "UDP" },
  ]
}

export const httpHeaderInsertions = (header) => {
  switch (header) {
    case "X-Forwarded-For":
      return {
        label: "X-Forwarded-For",
        value: "X-Forwarded-For",
        description:
          "When selected a X-Forwarded-For header is inserted into the request to the backend member that specifies the client IP address.",
      }
    case "X-Forwarded-Port":
      return {
        label: "X-Forwarded-Port",
        value: "X-Forwarded-Port",
        description:
          "When selected a X-Forwarded-Port header is inserted into the request to the backend member that specifies the listener port.",
      }
    case "X-Forwarded-Proto":
      return {
        label: "X-Forwarded-Proto",
        value: "X-Forwarded-Proto",
        description:
          "When selected a X-Forwarded-Proto header is inserted into the request to the backend member. HTTP for the HTTP listener protocol type, HTTPS for the TERMINATED_HTTPS listener protocol type.",
      }
    case "X-SSL-Client-Verify":
      return {
        label: "X-SSL-Client-Verify",
        value: "X-SSL-Client-Verify",
        description:
          "When selected a X-SSL-Client-Verify header is inserted into the request to the backend member that contains 0 if the client authentication was successful, or an result error number greater than 0 that align to the openssl veryify error codes.",
      }
    case "X-SSL-Client-Has-Cert":
      return {
        label: "X-SSL-Client-Has-Cert",
        value: "X-SSL-Client-Has-Cert",
        description:
          "When selected a X-SSL-Client-Has-Cert header is inserted into the request to the backend member that is ‘’true’’ if a client authentication certificate was presented, and ‘’false’’ if not. Does not indicate validity.",
      }
    case "X-SSL-Client-DN":
      return {
        label: "X-SSL-Client-DN",
        value: "X-SSL-Client-DN",
        description:
          "When selected a X-SSL-Client-DN header is inserted into the request to the backend member that contains the full Distinguished Name of the certificate presented by the client.",
      }
    case "X-SSL-Client-CN":
      return {
        label: "X-SSL-Client-CN",
        value: "X-SSL-Client-CN",
        description:
          "When selected a X-SSL-Client-CN header is inserted into the request to the backend member that contains the Common Name from the full Distinguished Name of the certificate presented by the client.",
      }
    case "X-SSL-Issuer":
      return {
        label: "X-SSL-Issuer",
        value: "X-SSL-Issuer",
        description:
          "When selected a X-SSL-Issuer header is inserted into the request to the backend member that contains the full Distinguished Name of the client certificate issuer.",
      }
    case "X-SSL-Client-SHA1":
      return {
        label: "X-SSL-Client-SHA1",
        value: "X-SSL-Client-SHA1",
        description:
          "When selected a X-SSL-Client-SHA1 header is inserted into the request to the backend member that contains the SHA-1 fingerprint of the certificate presented by the client in hex string format.",
      }
    case "X-SSL-Client-Not-Before":
      return {
        label: "X-SSL-Client-Not-Before",
        value: "X-SSL-Client-Not-Before",
        description:
          "When selected a X-SSL-Client-Not-Before header is inserted into the request to the backend member that contains the start date presented by the client as a formatted string YYMMDDhhmmss[Z].",
      }
    case "X-SSL-Client-Not-After":
      return {
        label: "X-SSL-Client-Not-After",
        value: "X-SSL-Client-Not-After",
        description:
          "When selected a X-SSL-Client-Not-After header is inserted into the request to the backend member that contains the end date presented by the client as a formatted string YYMMDDhhmmss[Z].",
      }
    case "ALL":
      return [
        {
          label: "X-Forwarded-For",
          value: "X-Forwarded-For",
          description:
            "When selected a X-Forwarded-For header is inserted into the request to the backend member that specifies the client IP address.",
        },
        {
          label: "X-Forwarded-Port",
          value: "X-Forwarded-Port",
          description:
            "When selected a X-Forwarded-Port header is inserted into the request to the backend member that specifies the listener port.",
        },
        {
          label: "X-Forwarded-Proto",
          value: "X-Forwarded-Proto",
          description:
            "When selected a X-Forwarded-Proto header is inserted into the request to the backend member. HTTP for the HTTP listener protocol type, HTTPS for the TERMINATED_HTTPS listener protocol type.",
        },
        {
          label: "X-SSL-Client-Verify",
          value: "X-SSL-Client-Verify",
          description:
            "When selected a X-SSL-Client-Verify header is inserted into the request to the backend member that contains 0 if the client authentication was successful, or an result error number greater than 0 that align to the openssl veryify error codes.",
        },
        {
          label: "X-SSL-Client-Has-Cert",
          value: "X-SSL-Client-Has-Cert",
          description:
            "When selected a X-SSL-Client-Has-Cert header is inserted into the request to the backend member that is ‘’true’’ if a client authentication certificate was presented, and ‘’false’’ if not. Does not indicate validity.",
        },
        {
          label: "X-SSL-Client-DN",
          value: "X-SSL-Client-DN",
          description:
            "When selected a X-SSL-Client-DN header is inserted into the request to the backend member that contains the full Distinguished Name of the certificate presented by the client.",
        },
        {
          label: "X-SSL-Client-CN",
          value: "X-SSL-Client-CN",
          description:
            "When selected a X-SSL-Client-CN header is inserted into the request to the backend member that contains the Common Name from the full Distinguished Name of the certificate presented by the client.",
        },
        {
          label: "X-SSL-Issuer",
          value: "X-SSL-Issuer",
          description:
            "When selected a X-SSL-Issuer header is inserted into the request to the backend member that contains the full Distinguished Name of the client certificate issuer.",
        },
        {
          label: "X-SSL-Client-SHA1",
          value: "X-SSL-Client-SHA1",
          description:
            "When selected a X-SSL-Client-SHA1 header is inserted into the request to the backend member that contains the SHA-1 fingerprint of the certificate presented by the client in hex string format.",
        },
        {
          label: "X-SSL-Client-Not-Before",
          value: "X-SSL-Client-Not-Before",
          description:
            "When selected a X-SSL-Client-Not-Before header is inserted into the request to the backend member that contains the start date presented by the client as a formatted string YYMMDDhhmmss[Z].",
        },
        {
          label: "X-SSL-Client-Not-After",
          value: "X-SSL-Client-Not-After",
          description:
            "When selected a X-SSL-Client-Not-After header is inserted into the request to the backend member that contains the end date presented by the client as a formatted string YYMMDDhhmmss[Z].",
        },
      ]
    default:
      return []
  }
}

export const advancedSectionRelation = (protocol) => {
  switch (protocol) {
    case "HTTP":
    case "HTTPS":
    case "TERMINATED_HTTPS":
    case "TCP":
      return true
    default:
      return false
  }
}

export const tlsPoolRelation = (protocol) => {
  switch (protocol) {
    case "HTTP":
      return false
    case "HTTPS":
      return false
    case "TERMINATED_HTTPS":
      return true
    case "TCP":
      return false
    default:
      return false
  }
}

export const protocolHeaderInsertionRelation = (protocol) => {
  switch (protocol) {
    case "HTTP":
      return [
        httpHeaderInsertions("X-Forwarded-For"),
        httpHeaderInsertions("X-Forwarded-Port"),
        httpHeaderInsertions("X-Forwarded-Proto"),
      ]
    case "HTTPS":
      return []
    case "TERMINATED_HTTPS":
      return httpHeaderInsertions("ALL")
    case "TCP":
      return []
    case "UDP":
      return []
    case "ALL":
      return httpHeaderInsertions("ALL")
    default:
      return []
  }
}

export const clientAuthenticationTypes = () => {
  return [
    { label: "NONE", value: "NONE" },
    { label: "OPTIONAL", value: "OPTIONAL" },
    { label: "MANDATORY", value: "MANDATORY" },
  ]
}

export const clientAuthenticationRelation = (protocol) => {
  switch (protocol) {
    case "TERMINATED_HTTPS":
      return clientAuthenticationTypes()
    default:
      return []
  }
}

export const certificateContainerRelation = (protocol) => {
  switch (protocol) {
    case "TERMINATED_HTTPS":
      return true
    default:
      return false
  }
}

export const SNIContainerRelation = (protocol) => {
  switch (protocol) {
    case "TERMINATED_HTTPS":
      return true
    default:
      return false
  }
}

export const CATLSContainerRelation = (protocol) => {
  switch (protocol) {
    case "TERMINATED_HTTPS":
      return true
    default:
      return false
  }
}

export const tlsCiphersRelation = (protocol) => {
  switch (protocol) {
    case "TERMINATED_HTTPS":
      return true
    default:
      return false
  }
}

export const predPolicyDesc = (policy) => {
  switch (policy) {
    case "proxy_protocol_2edF_v1_0":
      return {
        label: "Set Proxy Protocol (proxy_protocol_2edF_v1_0)",
        description: (
          <>
            Adds client IP/Port information to the TCP request{" "}
            <b>in text format.</b>
            <br />
            Format: PROXY TCP[VERSION] [REMOTE ADDR] [LOCAL ADDR] [REMOTE PORT]
            [LOCAL PORT] <br /> For more information please take a look at{" "}
            <a
              href="https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt"
              target="_blank"
            >
              the Proxy Protocol Specification.
            </a>
            <br />
            All backend members have to have Proxy Protocol Version 1 support
            enabled.
          </>
        ),
      }
    case "proxy_protocol_V2_e8f6_v1_0":
      return {
        label: "Set Proxy Protocol V2 (proxy_protocol_V2_e8f6_v1_0)",
        description: (
          <React.Fragment>
            Adds client IP information to the TCP request{" "}
            <b>strong in binary format</b>.<br />
            For more information please take a look at{" "}
            <a
              href="https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt"
              target="_blank"
            >
              the Proxy Protocol Specification.
            </a>
            <br /> All backend members have to have Proxy Protocol Version 2
            support enabled.
          </React.Fragment>
        ),
      }
    case "standard_tcp_a3de_v1_0":
      return {
        label: "Use Standard Profile (standard_tcp_a3de_v1_0)",
        description: (
          <React.Fragment>
            Switch listener from FastL4 to standard profile on F5 device. Use it
            only when FastL4 profile doesn't work for your application!!!{" "}
            <a
              href="https://support.f5.com/csp/article/K55185917"
              target="_blank"
            >
              (F5 Documentation)
            </a>
          </React.Fragment>
        ),
      }
    case "x_forward_5b6e_v1_0":
      return {
        label: "Set X-Forwarded Headers (x_forward_5b6e_v1_0)",
        description: (
          <React.Fragment>
            Adds X-FORWARDED-FOR/PROTO/PORT to HTTP header.
          </React.Fragment>
        ),
      }
    case "no_one_connect_3caB_v1_0":
      return {
        label: "Disable OneConnect (no_one_connect_3caB_v1_0)",
        description: (
          <React.Fragment>
            Disables the OneConnect Profile on listeners (used for member
            connection reuse){" "}
            <a href="https://support.f5.com/csp/article/K7208" target="_blank">
              (F5 Documentation)
            </a>
          </React.Fragment>
        ),
      }
    case "http_compression_e4a2_v1_0":
      return {
        label: "Enable HTTP compression (http_compression_e4a2_v1_0)",
        description: (
          <React.Fragment>
            Enables HTTP compression profile on listener. Compression is done
            with gzip for content types text/* and
            application/(xml|x-javascript).
          </React.Fragment>
        ),
      }
    case "cookie_encryption_b82a_v1_0":
      return {
        label: "Enable Cookie Encryption (cookie_encryption_b82a_v1_0)",
        description: (
          <React.Fragment>
            All cookies are encrypted when sent to client and decrypted when
            passed to backend members.
          </React.Fragment>
        ),
      }
    case "sso_22b0_v1_0":
      return {
        label: "Enable Client Authentication (SSO) (sso_22b0_v1_0)",
        description: (
          <React.Fragment>
            Prompts clients for certificates. Validates Client Ceritificates and
            adds various X-SSL-Client-Cert-* attributes to HTTP header. Expects
            listener (TERMINATED_HTTPS) certificate name used for SSL offloading
            starts with CATrust*
          </React.Fragment>
        ),
      }
    case "http_redirect_a26c_v1_0":
      return {
        label: "Redirect HTTP to HTTPS (http_redirect_a26c_v1_0)",
        description: (
          <React.Fragment>
            Redirects all HTTP calls to HTTPS protocol on port 443. A given path
            will also be added to the https redirect, i.e. http://sap.com/hana
            would result in https://sap.com/hana.
          </React.Fragment>
        ),
      }
    default:
      return []
  }
}

export const helpBlockItems = (protocol) => {
  return predefinedPolicies(protocol).map((item) => predPolicyDesc(item.value))
}

export const predefinedPolicies = (protocol) => {
  switch (protocol) {
    case "HTTP":
      return [
        { label: "x_forward_5b6e_v1_0", value: "x_forward_5b6e_v1_0" },
        {
          label: "no_one_connect_3caB_v1_0",
          value: "no_one_connect_3caB_v1_0",
        },
        {
          label: "http_compression_e4a2_v1_0",
          value: "http_compression_e4a2_v1_0",
        },
        {
          label: "cookie_encryption_b82a_v1_0",
          value: "cookie_encryption_b82a_v1_0",
        },
        {
          label: "http_redirect_a26c_v1_0",
          value: "http_redirect_a26c_v1_0",
        },
        {
          label: "proxy_protocol_2edF_v1_0",
          value: "proxy_protocol_2edF_v1_0",
        },
        {
          label: "proxy_protocol_V2_e8f6_v1_0",
          value: "proxy_protocol_V2_e8f6_v1_0",
        },
        { label: "standard_tcp_a3de_v1_0", value: "standard_tcp_a3de_v1_0" },
      ]
    case "TERMINATED_HTTPS":
      return [
        { label: "x_forward_5b6e_v1_0", value: "x_forward_5b6e_v1_0" },
        {
          label: "no_one_connect_3caB_v1_0",
          value: "no_one_connect_3caB_v1_0",
        },
        {
          label: "http_compression_e4a2_v1_0",
          value: "http_compression_e4a2_v1_0",
        },
        {
          label: "cookie_encryption_b82a_v1_0",
          value: "cookie_encryption_b82a_v1_0",
        },
        { label: "sso_22b0_v1_0", value: "sso_22b0_v1_0" },
        {
          label: "proxy_protocol_2edF_v1_0",
          value: "proxy_protocol_2edF_v1_0",
        },
        {
          label: "proxy_protocol_V2_e8f6_v1_0",
          value: "proxy_protocol_V2_e8f6_v1_0",
        },
        { label: "standard_tcp_a3de_v1_0", value: "standard_tcp_a3de_v1_0" },
      ]
    case "HTTPS":
    case "TCP":
      return [
        {
          label: "proxy_protocol_2edF_v1_0",
          value: "proxy_protocol_2edF_v1_0",
        },
        {
          label: "proxy_protocol_V2_e8f6_v1_0",
          value: "proxy_protocol_V2_e8f6_v1_0",
        },
        { label: "standard_tcp_a3de_v1_0", value: "standard_tcp_a3de_v1_0" },
      ]
    case "UDP":
      return []
    default:
      return []
  }
}

export const isSecretAContainer = (secret) => {
  if (secret && secret.length > 0) {
    return secret.includes("container")
  }
  return false
}
