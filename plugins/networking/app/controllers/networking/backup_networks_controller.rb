# frozen_string_literal: true

module Networking
  # Implements Network actions
  class BackupNetworksController < DashboardController
    def index
      @backup_network = load_backup_networks.first
      @rbacs = load_rbacs(@backup_network)
    end

    def new
      @backup_network = load_backup_networks.first
      @rbacs = load_rbacs(@backup_network)
      @rbac = cloud_admin.networking.new_rbac
    end

    def create
      @backup_network = load_backup_networks.first
      @rbac = cloud_admin.networking.new_rbac(
        object_id: @backup_network.id,
        object_type: 'network',
        action: 'access_as_shared',
        target_tenant: @scoped_project_id
      )

      if @rbac.save
        render action: :create
      else
        @rbacs = load_rbacs(@backup_network)
        render action: :new
      end
    end

    protected

    def load_backup_networks
      name = "Private-backup-sap-#{@scoped_domain_name}"
      cloud_admin.networking.networks(
        'router:external' => false, name: name
      )
    end

    def load_rbacs(network)
      return if network.nil?
      cloud_admin.networking.rbacs(
        object_id: network.id,
        object_type: 'network',
        target_tenant: @scoped_project_id
      )
    end
  end
end
