module Networking
  class SecurityGroupsController < DashboardController
    def index
      @security_groups = services.networking.security_groups(tenant_id: @scoped_project_id)
      
      @quota_data = services.resource_management.quota_data([
        {service_name: :networking, resource_name: :security_groups, usage: @security_groups.length},
        {service_name: :networking, resource_name: :security_group_rules}
      ])
    end
    
    def new
      @security_group = services.networking.new_security_group(tenant_id: @scoped_project_id)
    end
    
    def create
      @security_group = services.networking.new_security_group((params[:security_group] || {}).merge(tenant_id: @scoped_project_id))
      @security_group.save
      
      if @security_group.errors.empty?
        respond_to do |format| 
          format.html {redirect_to security_groups_path}
          format.js{}
        end
      else
        render action: :new
      end
    end

    # Fog doesn't implement update functionality!  
    # def edit
    #   @security_group = services.networking.find_security_group(params[:id])
    # end
    #
    # def update
    #   @security_group = services.networking.find_security_group(params[:id])
    #   @security_group.attributes = (params[:security_group] || {}).merge(tenant_id: @scoped_project_id)
    #   @security_group.save
    #
    #   if @security_group.errors.empty?
    #     respond_to do |format|
    #       format.html {redirect_to :back}
    #       format.js{}
    #     end
    #   else
    #     render action: :edit
    #   end
    # end
    
    def show
      @security_group = services.networking.find_security_group(params[:id])
      @rules = services.networking.security_group_rules(security_group_id: @security_group.id)
      @security_groups = {}
      @rules.each do |rule|
        unless @security_groups[rule.remote_group_id]
          if rule.remote_group_id==@security_group.id
            @security_groups[rule.remote_group_id] = @security_group
          else  
            @security_groups[rule.remote_group_id] = services.networking.find_security_group(rule.remote_group_id) rescue nil
          end
        end  
        rule.remote_group_name = @security_groups[rule.remote_group_id].name if @security_groups[rule.remote_group_id]
      end
      
      @quota_data = services.resource_management.quota_data([
        {service_name: :networking, resource_name: :security_groups, usage: @security_groups.length},
        {service_name: :networking, resource_name: :security_group_rules, usage: @rules.length}
      ])
    end
    
    def destroy
      @security_group = services.networking.find_security_group(params[:id])
      
      success = true
      
      if @security_group
        unless @security_group.destroy
          @error = @security_group.errors.full_messages.to_sentence
        end
      else
        @error = 'Could not find security group.'
      end
      
      respond_to do |format|
        format.html do 
          if @error 
            flash.now[:error] = @error
          else
            flash.now[:notice] = 'Security Group successfully deleted!'  
          end
          redirect_to security_groups_path 
        end
        format.js { }
      end
    end
  end
end
