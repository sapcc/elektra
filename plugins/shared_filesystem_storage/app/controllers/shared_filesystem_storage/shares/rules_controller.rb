# frozen_string_literal: true

module SharedFilesystemStorage
  module Shares
    # This class implements the access control
    class RulesController < ApplicationController
      authorization_context "shared_filesystem_storage"
      authorization_required

      def index
        render json:
                 services.shared_filesystem_storage.share_rules(
                   params[:share_id],
                 )
      end

      def create
        rule =
          services.shared_filesystem_storage.new_share_rule(
            params[:share_id],
            rule_params,
          )

        if rule.save
          add_permissions(rule)
          render json: rule
        else
          render json: { errors: rule.errors }
        end
      end

      def destroy
        rule =
          services.shared_filesystem_storage.new_share_rule(params[:share_id])
        rule.id = params[:id]

        if rule.destroy
          head :no_content
        else
          render json: { errors: rule.errors }
        end
      end

      protected

      def rule_params
        params.require(:rule).permit(:access_type, :access_level, :access_to)
      end

      def add_permissions(rule)
        rule.permissions = {
          delete:
            current_user.is_allowed?("shared_filesystem_storage:rule_delete"),
          update:
            current_user.is_allowed?("shared_filesystem_storage:rule_update"),
        }
      end
    end
  end
end
