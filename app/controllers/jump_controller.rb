class JumpController < ::ApplicationController
  layout 'plain'

  def index
    project = ObjectCache.where(
      cached_object_type: 'project', 
      id: params[:project_id]
    ).first || cloud_admin.identity.find_project(params[:project_id])

    render action: :index and return unless project

    path = "/#{project.domain_id}/#{project.id}"
    path += params[:rest] ? "/#{params[:rest]}" : '/home' 
    redirect_to(path)
  end

  def show
    @objects = ObjectCache
      .where(id: params[:object_id])
      .joins("LEFT JOIN object_cache projects ON projects.id = object_cache.project_id") 
      .joins("LEFT JOIN object_cache domains ON domains.id = projects.domain_id")
      .pluck("object_cache.id,object_cache.name,object_cache.cached_object_type,object_cache.project_id,projects.name,projects.domain_id,domains.name,object_cache.payload")
      .map do |o| 
      #byebug

      OpenStruct.new(
        id: o[0], 
        name: o[1], 
        type: o[2], 
        project_id: o[3], 
        project_name: o[4], 
        domain_id: o[5], 
        domain_name: o[6],
        url: object_url(type: o[2], domain_id: o[5], project_id: o[3], id: o[0]),
        payload: o[7]
      )
    end

    redirect_to @objects.first.url and return if @objects.length == 1 && @objects.first.url
  end

  protected

  def object_url(type:,domain_id:,project_id:,id:)
    return nil unless (domain_id && project_id && id)
    
    case type
    when 'domain' 
      domain_home_url(domain_id)
    when 'flavor'
      plugin('compute').flavors_url(domain_id: domain_id, project_id: project_id)
    when 'floatingip' 
      plugin('networking').floating_ip_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'image'      
      plugin('image').ng_url(domain_id: domain_id, project_id: project_id)
    when 'l7policy', 'listener'   
      plugin('loadbalancing').loadbalancers_url(domain_id: domain_id, project_id: project_id)
    when 'network'    
      plugin('networking').networks_external_url(domain_id: domain_id, project_id: project_id)
    when 'port'       
      plugin('networking').port_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'project'    
      plugin('identity').project_url(domain_id: domain_id, project_id: project_id)
    when 'router'     
      plugin('networking').router_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'recordset'  
      plugin('dns_service').zone_recordset_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'server'   
      plugin('compute').instance_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'volume'     
      plugin('block_storage').volume_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'zone'       
      plugin('dns_service').zone_recordsets_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'loadbalancer'   
      plugin('loadbalancing').loadbalancer_listeners_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'security_group' 
      plugin('networking').security_group_url(domain_id: domain_id, project_id: project_id, id: id)
    when 'share_network', 'share_server', 'share', 'share_type'   
      plugin('shared_filesystem_storage').start(domain_id: domain_id, project_id: project_id)
    when 'security_group_rule' 
      plugin('networking').security_groups_url(domain_id: domain_id, project_id: project_id)
    when 'project_group_role_assignment','project_user_role_assignment'  
      plugin('identity').projects_role_assignments_url(domain_id: domain_id, project_id: project_id)
    else
      if domain_id && project_id
        return object_url(type: 'project', domain_id: domain_id, project_id: project_id, id: id)
      end
      if domain_id 
        return object_url(type: 'domain', doamin_id: domain_id, project_id: project_id, id: id)
      end
      nil
    end
  end
end
