# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Keypair
      def keypairs
        # keypair structure different to others, so manual effort needed
        return @user_keypairs if @user_keypairs

        keypairs = api.compute.list_keypairs.map_to(Compute::Keypair)
        @user_keypairs = keypairs.each_with_object([]) do |k, user_keypairs|
          user_keypairs << map_to(Compute::Keypair, k.keypair) if k.keypair
        end
      end

      def new_keypair(params = {})
        # this is used for inital create keypair dialog
        map_to(Compute::Keypair, params)
      end

      def create_keypair(attributes = {})
        api.compute.create_or_import_keypair(keypair: attributes).data
      end

      def find_keypair!(keypair_name)
        return nil if keypair_name.blank?
        api.compute.show_keypair_details(keypair_name).map_to(Compute::Keypair)
      end

      def find_keypair(keypair_name)
        find_keypair!(keypair_name)
      rescue
        nil
      end

      def delete_keypair(keypair_name)
        return nil if keypair_name.blank?
        api.compute.delete_keypair(keypair_name)
      end
    end
  end
end
