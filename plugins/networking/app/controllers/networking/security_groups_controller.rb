# frozen_string_literal: true

module Networking
  # Implements Security Group actions
  class SecurityGroupsController < DashboardController
    authorization_context "networking"
    authorization_required

    def index
      # this function is called when the user opens the security groups page and the ajax call is made
      all_security_groups = []
      # get the first 500 security groups
      security_groups = services.networking.security_groups()
      all_security_groups = security_groups
      # get all security groups until the limit of 500 is reached
      while security_groups.length == 500
        marker = security_groups.last.id
        security_groups = services.networking.security_groups({marker: marker})
        all_security_groups += security_groups
      end
      # puts "######### all_security_groups: #{all_security_groups.length}"
      # render the security groups as json to consume them in the react frontend
      render json: { security_groups: all_security_groups }
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
