# frozen_string_literal: true

module Galvani
  class TagsController < ::AjaxController

    def index
      project = cloud_admin.identity.find_project(@scoped_project_id)
      render json: { tags: filter_tags(project.tags) }
    rescue Elektron::Errors::ApiResponse => e
      puts "error elektron"
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      puts "generic error"
      render json: { errors: e.message }, status: "500"
    end

    def create
      tag = params[:tag]
      unless validate(tag).nil?
        render json: {errors: "tag is empty!"}, status: 422
      end

      project = cloud_admin.identity.find_project(@scoped_project_id)
      project.tags << tag
      if project.save 
        audit_logger.info(current_user, 'has created tag', tag)
        render json: { tags: project.tags }
      else
        render json: {errors: project.errors}, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def destroy
      tag = params[:tag]
      unless validate(tag).nil?
        render json: {errors: "tag is empty!"}, status: 422
      end

      project = cloud_admin.identity.find_project(@scoped_project_id)
      project.tags.delete_if {|i| i == tag} unless tags.blank?
      if project.save 
        audit_logger.info(current_user, 'has created tag', tag)
        render json: { tags: project.tags }
      else
        render json: {errors: project.errors}, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    private

    # return all galvani tags --> prefixes from config file xs:internet, ...
    # the base prefixes should be removed
    def filter_tags(tags)
      if tags.blank?
        return []
      end
      tags.select { |n| n.start_with?("xs:internet") }
    end

    # add/remove base prefix from the tags list
    def ensure_base_prefix()
    end

    # tag starts with a base access prefix from the config
    # tag has as a service one of the prefixes from the base access prefixes
    def validate_tag(tag)
      # check for access profiles
      unless tag.start_with?("xs:internet")
        return false, "tag has to start with prefix 'xs:internet'"
      end
      return true, nil
    end

  end
end
