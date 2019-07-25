ALLOWED_ROLES = %w[
  admin
  audit_viewer
  automation_admin
  automation_viewer
  compute_admin
  compute_admin_wsg
  compute_viewer
  dns_viewer
  dns_webmaster
  image_admin
  image_viewer
  keymanager_admin
  keymanager_viewer
  kubernetes_admin
  kubernetes_member
  member
  monitoring_viewer
  network_admin
  network_viewer
  role_admin
  role_viewer
  resource_admin
  resource_viewer
  sharedfilesystem_admin
  sharedfilesystem_viewer
  swiftoperator
  volume_admin
  volume_viewer
  securitygroup_viewer
  securitygroup_admin
].freeze

BETA_ROLES = %w[
].freeze

# not even cloud admins are allowed to assign these, they're intentionally
# restricted to a few technical users and CAM-managed groups (and those
# assignments are maintained in helm-charts)
BLACKLISTED_ROLES = %w[
  cloud_resource_admin
  cloud_resource_viewer
  resource_service
  swiftreseller
].freeze
