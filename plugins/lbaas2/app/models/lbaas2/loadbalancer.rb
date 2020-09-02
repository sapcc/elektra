# frozen_string_literal: true

module Lbaas2
  # represents openstack lb
  class Loadbalancer < Core::ServiceLayer::Model
    validates :vip_subnet_id, presence: true, unless: ->(lb){lb.vip_network_id.present?}
    validates :vip_network_id, presence: true, unless: ->(lb){lb.vip_subnet_id.present?}
    validates :name, presence: true

    def attributes_for_create
      {
        'name'            => read('name'),
        'description'     => read('description'),
        'vip_network_id'   => read('vip_network_id'),
        'vip_subnet_id'   => read('vip_subnet_id'),
        'vip_address'     => read('vip_address'),        
        'project_id'      => read('project_id'),
        'tags'            => read('tags')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'            => read('name'),
        'description'     => read('description'),
        'admin_state_up'  => read('admin_state_up'),
        'tags'            => read('tags')
      }
    end

  end
end
