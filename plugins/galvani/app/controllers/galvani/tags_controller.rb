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
      ok, err = validate_tag(tag)
      unless ok
        return render json: {errors: err, tagSpec: GalvaniConfig["access_profiles"]}, status: 422        
      end
      # cloud_admin.identity.add_single_tag(@scoped_project_id, tag)
      # audit_logger.info(current_user, 'has created tag', tag)
      render json: { tag: tag }
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

      cloud_admin.identity.remove_single_tag(@scoped_project_id, tag)      
      audit_logger.info(current_user, 'has deleted tag', tag)
      render json: { tag: tag }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def profiles_config

      puts "---config--"
      puts GalvaniConfig["access_profiles"]
      puts "------"

      render json: { config: GalvaniConfig["access_profiles"] }
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    private

    # def profile_tag_mapper(profiles_cfg, tags)
    #   new_profiles_cfg = profiles_cfg || {}
    #   new_tags = tags || []
      
    #   new_profiles_cfg.keys.each { |key| new_tags.select { |n| n.start_with?(key) }}
    # end

    # return all galvani tags --> prefixes from config file xs:internet, ...
    # the base prefixes should be removed
    def filter_tags(tags)
      if tags.blank?
        return []
      end
      
      puts "=========="
      profile_prefixes = GalvaniConfig["access_profiles"].keys || []
      puts profile_prefixes
      puts "=========="

      # array with splat operator(*)
      # select returns a new array
      tags.select { |n| n.start_with?(*profile_prefixes) }
    end

    # add/remove base prefix from the tags list
    def ensure_base_prefix()
    end

    # Config flatten access profile with service ending up to such prefixes xs:internet:keppel_account_pull
    # validate that tag starts with one of this prefixes
    def validate_tag(tag)
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

      return true, ""
    end



  end
end
