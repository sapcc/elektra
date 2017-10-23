# frozen_string_literal: true

module Networking
  # Implements Network actions
  class BackupNetworksController < DashboardController
    def index
      byebug
    end

    def new
    end

    def create

    end

    protected

    def load_backup_networks
      @backup_networks = cloud_admin.networking.networks(
        'router:external' => false
      ).select do |n|
        name = n.name || ''
        name.include?(@scoped_domain_name) && name.downcase.include?('backup')
      end
    end
  end
end
