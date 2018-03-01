ALLOWED_ROLES = %w(
  admin
  audit_viewer
  compute_admin
  compute_viewer
  dns_viewer
  keymanager_admin
  keymanager_viewer
  member
  monitoring_viewer
  network_admin
  network_viewer
  resource_admin
  resource_viewer
  sharedfilesystem_admin
  sharedfilesystem_viewer
  swiftoperator
  volume_admin
  volume_viewer
).freeze

BETA_ROLES = %w(
  kubernetes_admin
).freeze
