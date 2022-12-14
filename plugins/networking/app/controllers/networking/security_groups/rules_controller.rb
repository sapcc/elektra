# frozen_string_literal: true

require "ipaddr"

module Networking
  module SecurityGroups
    # Implements Security Group Rule actions
    class RulesController < ::DashboardController
      authorization_context "networking"
      authorization_required

      def create
        security_group_rule = services.networking.new_security_group_rule
        security_group_rule.attributes = params[:security_group_rule]
        security_group_rule.security_group_id = params[:security_group_id]

        if security_group_rule.save
          render json: security_group_rule
        else
          render json: { errors: security_group_rule.errors }, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      end

      def destroy
        security_group_rule = services.networking.new_security_group_rule
        security_group_rule.id = params[:id]

        if security_group_rule.destroy
          head 202
        else
          render json: { errors: security_group_rule.errors }, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      end
    end
  end
end
