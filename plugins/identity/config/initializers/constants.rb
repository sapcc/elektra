ALLOWED_ROLES = %w(
  admin
  compute_admin
  compute_viewer
  dns_viewer
  member
  monitoring_viewer
  network_admin
  network_viewer
  sharedfilesystem_admin
  sharedfilesystem_viewer
  swiftoperator
  volume_admin
  volume_viewer
  audit_viewer
).freeze

BETA_ROLES = %w(
  kubernetes_admin
).freeze
