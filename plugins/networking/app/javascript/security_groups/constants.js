// SECURITY_GROUPS
export const REQUEST_SECURITY_GROUPS                  = 'networking/security_groups/REQUEST_SECURITY_GROUPS';
export const RECEIVE_SECURITY_GROUPS                  = 'networking/security_groups/RECEIVE_SECURITY_GROUPS';
export const REQUEST_SECURITY_GROUPS_FAILURE          = 'networking/security_groups/REQUEST_SECURITY_GROUPS_FAILURE';
export const RECEIVE_SECURITY_GROUP                   = 'networking/security_groups/RECEIVE_SECURITY_GROUP';
export const REQUEST_SECURITY_GROUP_DELETE            = 'networking/security_groups/REQUEST_SECURITY_GROUP_DELETE';
export const REMOVE_SECURITY_GROUP                    = 'networking/security_groups/REMOVE_SECURITY_GROUP';

// RULES
export const REMOVE_SECURITY_GROUP_RULE               = 'networking/security_groups/REMOVE_SECURITY_GROUP_RULE';
export const RECEIVE_SECURITY_GROUP_RULE              = 'networking/security_groups/RECEIVE_SECURITY_GROUP_RULE';
export const REQUEST_SECURITY_GROUP_RULE_DELETE       = 'networking/security_groups/REQUEST_SECURITY_GROUP_RULE_DELETE';

export const SECURITY_GROUP_RULE_PROTOCOLS = [
  {
    key: 'tcp',
    label: 'TCP',
  },
  {
    key: 'udp',
    label: 'UDP'
  },
  {
    key: 'icmp',
    label: 'ICMP'
  }
]

export const SECURITY_GROUP_RULE_DESCRIPTIONS = [
  {key: 'rules', title: 'Rules', text: "Rules define which traffic is allowed to instances assigned to the security group. A security group rule consists of three main parts: Type, Port Range and Remote Source."},
  {key: 'type', title: 'Type', text: "You can specify the desired rule template or use custom rules, the options are Custom TCP Rule, Custom UDP Rule, or Custom ICMP Rule."},
  {key: 'portRange', title: 'Port Range', text: "For TCP and UDP rules you may choose to open either a single port or a range of ports. For as range provide the starting and ending ports devided by minus (e.g. 0-80)."},
  {key: 'icmp', title: 'ICMP', text: "For ICMP rules you should specify an ICMP type and code in the spaces provided."},
  {key: 'remote', title: 'Remote', text: "You must specify the source of the traffic to be allowed via this rule. You may do so either in the form of an IP address block (CIDR, recommended) or via a source group (Security Group, not recommended). Selecting a security group as the source will allow any other instance in that security group access."}
]

export const SECURITY_GROUP_RULE_PREDEFINED_TYPES = [
  {
    label: "Custom TCP Rule",
    protocol: "tcp",
    direction: null,
    portRange: null
  },
  {
    label: "Custom UDP Rule",
    protocol: "udp",
    direction: null,
    portRange: null
  },
  {
    label: 'Custom ICMP Rule',
    protocol: 'icmp',
    direction: null,
    portRange: null
  },
  {
    label: 'All TCP',
    protocol: 'tcp',
    portRange: '1 - 65535',
    direction: null
  },
  {
    label: 'All UDP',
    protocol: 'udp',
    portRange: '1 - 65535',
    direction: null
  },
  {
    label: 'All ICMP',
    protocol: 'icmp',
    portRange: null,
    direction: null
  },
  {
    label: 'Other Protocol',
    protocol: null,
    direction: null,
    portRange: null
  },
  {
    label: 'DNS',
    protocol: 'tcp',
    portRange: 53,
    direction: 'ingress'
  },
  {
    label: 'HTTP',
    protocol: 'tcp',
    portRange: 80,
    direction: 'ingress'
  },
  {
    label: 'HTTPS',
    protocol: 'tcp',
    portRange: 443,
    direction: 'ingress'
  },
  {
    label: 'IMAP',
    protocol: 'tcp',
    portRange: 143,
    direction: 'ingress'
  },
  {
    label: 'IMAPS',
    protocol: 'tcp',
    portRange: 993,
    direction: 'ingress'
  },
  {
    label: 'LDAP',
    protocol: 'tcp',
    portRange: 389,
    direction: 'ingress'
  },
  {
    label: 'MS SQL',
    protocol: 'tcp',
    portRange: 1433,
    direction: 'ingress'
  },
  {
    label: 'MYSQL',
    protocol: 'tcp',
    portRange: 3306,
    direction: 'ingress'
  },
  {
    label: 'POP3',
    protocol: 'tcp',
    portRange: 110,
    direction: 'ingress'
  },
  {
    label: 'POP3S',
    protocol: 'tcp',
    portRange: 995,
    direction: 'ingress'
  },
  {
    label: 'RDP',
    protocol: 'tcp',
    portRange: 3389,
    direction: 'ingress'
  },
  {
    label: 'SSH',
    protocol: 'tcp',
    portRange: 22,
    direction: 'ingress'
  },
  {
    label: 'SMTP',
    protocol: 'tcp',
    portRange: 25,
    direction: 'ingress'
  },
  {
    label: 'SMTPS',
    protocol: 'tcp',
    portRange: 465,
    direction: 'ingress'
  }
]
