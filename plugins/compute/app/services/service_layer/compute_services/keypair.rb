# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Compute Keypair API
    module Keypair
      def keypair_map
        @keypair_map ||= class_map_proc(Compute::Keypair)
      end

      def keypairs
        # keypair structure different to others, so manual effort needed
        return @user_keypairs if @user_keypairs
        keypairs = elektron_compute.get("os-keypairs").body["keypairs"]

        @user_keypairs =
          keypairs.each_with_object([]) do |k, array|
            array << keypair_map.call(k["keypair"]) if k["keypair"]
          end
      end

      def find_keypair!(keypair_name)
        return nil if keypair_name.blank?
        elektron_compute.get("os-keypairs/#{keypair_name}").map_to(
          "body.keypair",
          &keypair_map
        )
      end

      def find_keypair(keypair_name)
        find_keypair!(keypair_name)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_keypair(params = {})
        # this is used for inital create keypair dialog
        keypair_map.call(params)
      end

      ################## MODEL INTERFACE #################
      def create_keypair(attributes = {})
        elektron_compute
          .post("os-keypairs") { { "keypair" => attributes } }
          .body[
          "keypair"
        ]
      end

      def delete_keypair(keypair_name)
        return nil if keypair_name.blank?
        elektron_compute.delete("os-keypairs/#{keypair_name}")
      end
    end
  end
end
