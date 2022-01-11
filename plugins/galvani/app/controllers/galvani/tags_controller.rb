# frozen_string_literal: true

module Galvani
  class TagsController < ::AjaxController

    # Returns project tags relevant to galvani
    # tags are filtered with the configuration file provided
    def index
      tags = cloud_admin.identity.list_tags(@scoped_project_id)
      render json: { tags: filter_tags(tags) }
    rescue Elektron::Errors::ApiResponse => e
      puts "error elektron"
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      puts "generic error"
      render json: { errors: e.message }, status: "500"
    end

    def create
      tag = params[:tag]
      tags = cloud_admin.identity.list_tags(@scoped_project_id)
      ok, err = validate_tag(tag, filter_tags(tags), "create")
      unless ok
        return render json: {errors: err, tagSpec: GalvaniConfig["access_profiles"]}, status: 422        
      end
      cloud_admin.identity.add_single_tag(@scoped_project_id, tag)
      audit_logger.info(current_user, 'has created tag', tag)
      render json: { tag: tag }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def destroy
      tag = params[:id]
      tags = cloud_admin.identity.list_tags(@scoped_project_id)
      ok, err = validate_tag(tag, filter_tags(tags), "destroy")
      unless ok
        return render json: {errors: err, tagSpec: GalvaniConfig["access_profiles"]}, status: 422        
      end

      cloud_admin.identity.remove_single_tag(@scoped_project_id, tag)      
      audit_logger.info(current_user, 'has deleted tag', tag)
      render json: { tag: tag }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def profiles_config
      render json: { config: GalvaniConfig["access_profiles"] }
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
      profile_prefixes = GalvaniConfig["access_profiles"].keys || []
      # array with splat operator(*), select returns a new array
      tags.select { |n| n.start_with?(*profile_prefixes) }
    end

    # add/remove base prefix from the tags list
    def ensure_base_prefix()
    end

    # validate that tag 
    def validate_tag(tag, existing_tags, action)
      # check for empty tags
      if tag.blank?
        return false, "access profile is empty!"
      end

      # get for base prefix
      base_prefixes = GalvaniConfig["access_profiles"].keys.select do|n| 
        tag.start_with?(n)
      end

      if base_prefixes.blank?
        return false, "no access profile found"
      end

      base_prefix = base_prefixes[0]
      # get the sercice
      services = GalvaniConfig["access_profiles"][base_prefix].keys.select do|k| 
        # service is everyting until the arguments $1, $2...
        serviceKey = k.split(":$").first
        tag.start_with?(base_prefix + ":" + serviceKey)
      end

      if services.blank?
        return false, "no service found"
      end

      service = services[0]
      # get the service args
      service_name_args = service.split(":$")
      service_name = service_name_args.shift
      service_args = service_name_args
      # get the tag arguments
      tag_args_str = tag.split(base_prefix + ":" + service_name + ":")[1] || ""
      tag_args = tag_args_str.split(":")

      # check for required args from the config
      if service_args.length != tag_args.length
        return false, "provided arguments mismatch"
      end    

      if action == "create"
        # check for duplicates when creating new tags
        if existing_tags.include?(tag)
          return false, "access profile already exists" 
        end
      end

      return true, ""
    end



  end
end
