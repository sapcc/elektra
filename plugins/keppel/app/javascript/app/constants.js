export const REQUEST_ACCOUNTS         = 'keppel/REQUEST_ACCOUNTS';
export const RECEIVE_ACCOUNTS         = 'keppel/RECEIVE_ACCOUNTS';
export const REQUEST_ACCOUNTS_FAILURE = 'keppel/REQUEST_ACCOUNTS_FAILURE';
export const UPDATE_ACCOUNT           = 'keppel/UPDATE_ACCOUNT';
export const DELETE_ACCOUNT           = 'keppel/DELETE_ACCOUNT';

export const REQUEST_PEERS         = 'keppel/REQUEST_PEERS';
export const RECEIVE_PEERS         = 'keppel/RECEIVE_PEERS';
export const REQUEST_PEERS_FAILURE = 'keppel/REQUEST_PEERS_FAILURE';

export const REQUEST_REPOSITORIES          = 'keppel/REQUEST_REPOSITORIES';
export const RECEIVE_REPOSITORIES          = 'keppel/RECEIVE_REPOSITORIES';
export const REQUEST_REPOSITORIES_FINISHED = 'keppel/REQUEST_REPOSITORIES_FINISHED';
export const REQUEST_REPOSITORIES_FAILURE  = 'keppel/REQUEST_REPOSITORIES_FAILURE';
export const DELETE_REPOSITORY             = 'keppel/DELETE_REPOSITORY';

export const REQUEST_MANIFESTS          = 'keppel/REQUEST_MANIFESTS';
export const RECEIVE_MANIFESTS          = 'keppel/RECEIVE_MANIFESTS';
export const REQUEST_MANIFESTS_FINISHED = 'keppel/REQUEST_MANIFESTS_FINISHED';
export const REQUEST_MANIFESTS_FAILURE  = 'keppel/REQUEST_MANIFESTS_FAILURE';
export const REQUEST_MANIFEST          = 'keppel/REQUEST_MANIFEST';
export const RECEIVE_MANIFEST          = 'keppel/RECEIVE_MANIFEST';
export const REQUEST_MANIFEST_FAILURE  = 'keppel/REQUEST_MANIFEST_FAILURE';
export const DELETE_MANIFEST            = 'keppel/DELETE_MANIFEST';

export const REQUEST_BLOB          = 'keppel/REQUEST_BLOB';
export const RECEIVE_BLOB          = 'keppel/RECEIVE_BLOB';
export const REQUEST_BLOB_FAILURE  = 'keppel/REQUEST_BLOB_FAILURE';

export const REQUEST_VULNS          = 'keppel/REQUEST_VULNS';
export const RECEIVE_VULNS          = 'keppel/RECEIVE_VULNS';
export const REQUEST_VULNS_FAILURE  = 'keppel/REQUEST_VULNS_FAILURE';

//sorting order for severities in image list and image details views
export const SEVERITY_ORDER = {
  "Pending": -2, //pseudo-severity: not scanned yet
  "Clean": -1,   //pseudo-severity: no vulnerabilities found
  "Unknown": 0,
  "Negligible": 1,
  "Low": 2,
  "Medium": 3,
  "High": 4,
  "Critical": 5,
  "Defcon1": 6,
};
