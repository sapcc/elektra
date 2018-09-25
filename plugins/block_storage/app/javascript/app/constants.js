export const REQUEST_VOLUMES =                 'block_storage/app/REQUEST_VOLUMES'
export const RECEIVE_VOLUMES =                 'block_storage/app/RECEIVE_VOLUMES'
export const REQUEST_VOLUMES_FAILURE =         'block_storage/app/REQUEST_VOLUME_FAILURE'
export const RECEIVE_VOLUME =                  'block_storage/app/RECEIVE_VOLUME'
export const SET_VOLUME_SEARCH_TERM =          'block_storage/app/SET_VOLUME_SEARCH_TERM'
export const REQUEST_VOLUME_DELETE =           'block_storage/app/REQUEST_VOLUME_DELETE'
export const REMOVE_VOLUME =                   'block_storage/app/REMOVE_VOLUME'
export const REQUEST_VOLUME_ATTACH =           'block_storage/app/REQUEST_VOLUME_ATTACH'
export const REQUEST_VOLUME_DETACH =           'block_storage/app/REQUEST_VOLUME_DETACH'

export const REQUEST_AVAILABILITY_ZONES =      'block_storage/app/REQUEST_AVAILABILITY_ZONES'
export const RECEIVE_AVAILABILITY_ZONES =      'block_storage/app/RECEIVE_AVAILABILITY_ZONES'
export const REQUEST_AVAILABILITY_ZONES_FAILURE = 'block_storage/app/REQUEST_AVAILABILITY_ZONE_FAILURE'

export const REQUEST_SNAPSHOTS =               'block_storage/app/REQUEST_SNAPSHOTS'
export const RECEIVE_SNAPSHOTS =               'block_storage/app/RECEIVE_SNAPSHOTS'
export const REMOVE_SNAPSHOT =                'block_storage/app/REMOVE_SNAPSHOT'
export const REQUEST_SNAPSHOTS_FAILURE =       'block_storage/app/REQUEST_SNAPSHOT_FAILURE'
export const REQUEST_SNAPSHOT_DELETE =        'block_storage/app/REQUEST_SNAPSHOT_DELETE'
export const RECEIVE_SNAPSHOT =                'block_storage/app/RECEIVE_SNAPSHOT'
export const SET_SNAPSHOT_SEARCH_TERM =        'block_storage/app/SET_SNAPSHOT_SEARCH_TERM'

//##################### SERVERS ###########################
export const REQUEST_SERVERS =                 'block_storage/app/REQUEST_SERVERS'
export const RECEIVE_SERVERS =                 'block_storage/app/RECEIVE_SERVERS'
export const REQUEST_SERVERS_FAILURE =         'block_storage/app/REQUEST_SERVER_FAILURE'

//#################### VOLUEM STATES #######################
export const VOLUME_STATE_CREATING = 'creating'
export const VOLUME_STATE_AVAILABLE = 'available'
export const VOLUME_STATE_ATTACHING = 'attaching'
export const VOLUME_STATE_DETACHING = 'detaching'
export const VOLUME_STATE_IN_USE = 'in-use'
export const VOLUME_STATE_MAINTENANCE = 'maintenance'
export const VOLUME_STATE_DELETING = 'deleting'
export const VOLUME_STATE_AWAITING_TRANSFER = 'awaiting-transfer'
export const VOLUME_STATE_ERROR = 'error'
export const VOLUME_STATE_ERROR_DELETING = 'error_deleting'
export const VOLUME_STATE_BACKING_UP = 'backing-up'
export const VOLUME_STATE_RESTORING_BACKUP = 'restoring-backup'
export const VOLUME_STATE_ERROR_BACKING_UP = 'error_backing-up'
export const VOLUME_STATE_ERROR_RESTORING = 'error_restoring'
export const VOLUME_STATE_ERROR_EXTENDING = 'error_extending'
export const VOLUME_STATE_DOWNLOADING = 'downloading'
export const VOLUME_STATE_UPLOADING = 'uploading'
export const VOLUME_STATE_RETYPING = 'retyping'
export const VOLUME_STATE_EXTENDING = 'extending'
export const VOLUME_STATE_ATTACHED = 'attached'
export const VOLUME_STATE_DETACHED = 'detached'

export const VOLUME_PENDING_STATUS = [
  VOLUME_STATE_CREATING,VOLUME_STATE_DELETING,VOLUME_STATE_ATTACHING,
  VOLUME_STATE_DETACHING,VOLUME_STATE_EXTENDING,VOLUME_STATE_RETYPING,
  VOLUME_STATE_UPLOADING,VOLUME_STATE_DOWNLOADING,
  VOLUME_STATE_AWAITING_TRANSFER
]

export const VOLUME_RESET_STATUS = [
  VOLUME_STATE_AVAILABLE, VOLUME_STATE_ERROR
]

export const VOLUME_RESET_ATTACH_STATUS = [
  VOLUME_STATE_ATTACHED, VOLUME_STATE_DETACHED
]

//####################### SNAPSHOT STATES ########################
export const SNAPSHOT_STATE_CREATING         = 'creating' //The snapshot is being created.
export const SNAPSHOT_STATE_AVAILABLE        = 'available' //The snapshot is ready to use.
export const SNAPSHOT_STATE_DELETING         = 'deleting' //The snapshot is being deleted.
export const SNAPSHOT_STATE_BACKING_UP       = 'backing-up' //The snapshot is being backed up.
export const SNAPSHOT_STATE_ERROR            = 'error' //A snapshot creation error occurred.
export const SNAPSHOT_STATE_ERROR_DELETING   = 'error_deleting' //A snapshot deletion error occurred.
export const SNAPSHOT_STATE_DELETED          = 'deleted' //The snapshot has been deleted.
export const SNAPSHOT_STATE_UNMANAGING       = 'unmanaging' //The snapshot is being unmanaged.
export const SNAPSHOT_STATE_RESTORING        = 'restoring' //The snapshot is being restored to a volume.

export const SNAPSHOT_PENDING_STATUS = [
  SNAPSHOT_STATE_CREATING,SNAPSHOT_STATE_DELETING,SNAPSHOT_STATE_BACKING_UP,
  SNAPSHOT_STATE_BACKING_UP,SNAPSHOT_STATE_UNMANAGING,SNAPSHOT_STATE_RESTORING
]

export const SNAPSHOT_RESET_STATUS = [
  SNAPSHOT_STATE_AVAILABLE, SNAPSHOT_STATE_ERROR
]
