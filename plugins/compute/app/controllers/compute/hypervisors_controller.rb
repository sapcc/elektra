module Compute
  class HypervisorsController < Compute::ApplicationController
    before_action ->(id = params[:id] || params[:hypervisor_id]) { load_hv id }

    authorization_context 'compute'
    authorization_required

    def index
      host_az_map = services.compute.host_aggregates.each_with_object({}) do |aggregate,map|
        aggregate.hosts.each do |host|
          map[host] = aggregate.availability_zone
        end
      end
      @hypervisors = services.compute.hypervisors.map do |h|
        if h.attributes['service'] && !h.attributes['service']['host'].blank?
          h.availability_zone = host_az_map[h.attributes['service']['host']]
        end
        h.availability_zone ||= 'unknown'
        h
      end.sort_by!(&:availability_zone)
    end

    def show
    end

    private

    def load_hv(id)
      @hypervisor = services.compute.find_hypervisor(id)
    end
  end
end
