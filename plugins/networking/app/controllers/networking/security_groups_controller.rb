# frozen_string_literal: true

module Networking
  # Implements Security Group actions
  class SecurityGroupsController < DashboardController
    authorization_context 'networking'
    authorization_required

    def index
      security_groups = services.networking.security_groups

      # byebug
      render json: {
        security_groups: security_groups
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def show
      security_group = services.networking.find_security_group!(params[:id])
      render json: { security_group: security_group }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def create
      security_group = services.networking.new_security_group
      security_group.attributes = params[:security_group]

      if security_group.save
        render json: security_group
      else
        render json: { errors: security_group.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def update
      security_group = services.networking.find_security_group!(params[:id])

      if security_group.update(params[:security_group])
        render json: security_group
      else
        render json: { errors: security_group.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def destroy
      security_group = services.networking.new_security_group
      security_group.id = params[:id]

      if security_group.destroy
        head 202
      else
        render json: { errors: security_group.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end
  end
end
