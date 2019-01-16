# frozen_string_literal: true

module Resources
  class ApplicationController < DashboardController
    before_action :prepare_data_for_js

    def release_state
      'beta'
    end

    def project
      @js_data[:project_id] = params[:override_project_id] || @scoped_project_id
      @js_data[:domain_id]  = params[:override_domain_id]  || @scoped_domain_id
      @js_data[:cluster_id] = params[:cluster_id]          || 'current'
      render action: 'show'
    end

    def domain
      @js_data[:domain_id]  = params[:override_domain_id]  || @scoped_domain_id
      @js_data[:cluster_id] = params[:cluster_id]          || 'current'
      render action: 'show'
    end

    def cluster
      @js_data[:cluster_id] = params[:cluster_id] || 'current'
      render action: 'show'
    end

    private

    def prepare_data_for_js
      @js_data = {
        token:       current_user.token,
        limes_api:   current_user.service_url('resources'),
        flavor_data: fetch_baremetal_flavor_data,
      }
    end

    def fetch_baremetal_flavor_data
      mib = Core::DataType.new(:bytes, :mega)
      gib = Core::DataType.new(:bytes, :giga)
      result = {}

      cloud_admin.compute.flavors.each do |f|
        next unless f.name =~ /^z/

        # cache extra-specs between requests to keep rendering time down
        @@flavor_metadata_cache ||= {}
        m = (@@flavor_metadata_cache[f.id] ||=
          cloud_admin.compute.find_flavor_metadata(f.id))
        next if m.nil?

        primary = []
        primary << "#{f.vcpus} cores" if f.vcpus
        primary << "#{mib.format(f.ram.to_i)} RAM" if f.ram
        primary << "#{gib.format(f.disk.to_i)} disk" if f.disk
        result[f.name] = {
          primary: primary.join(', '),
          secondary: m.attributes['catalog:description'] || '',
        }
      end
      return result
    end

  end
end
