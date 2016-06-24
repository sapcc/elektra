module Identity
  class GroupsController < ::DashboardController

    def show
      enforce_permissions("identity:group_get",{domain_id: @scoped_domain_id})
      @group = services.identity.find_group(params[:id])
      @group_members = services.identity.group_members(params[:id])
    end
    
    def index
      enforce_permissions("identity:group_list",{domain_id: @scoped_domain_id})
      @groups = services.identity.groups(domain_id: @scoped_domain_id) 
    end
    
    def new_member
      @group = services.identity.find_group(params[:group_id]) 
      enforce_permissions("identity:group_add_member",{group: @group})
    end
    
    def add_member
      @group = services.identity.find_group(params[:group_id]) 
      enforce_permissions("identity:group_add_member",{group: @group})
      
      @group_members = services.identity.group_members(params[:group_id])
      
      @user = params[:user_name].blank? ? nil : begin 
        service_user.users(domain_id: @scoped_domain_id, name:params[:user_name]).first 
      rescue
        service_user.find_user(params[:user_name]) rescue nil
      end
      
      if @user.nil? or @user.id.nil?
        @error = "User not found."
        render action: :new_member
      elsif @group_members.find{|user| user.id==@user.id}
        @error = "User is already a member of this project."
        render action: :new_member
      elsif @user.domain_id!=@scoped_domain_id
        @error = "User is not a member of this domain."
        render action: :new_member
      else
        services.identity.add_group_member(@group.id,@user.id)
        audit_logger.info(current_user, "has added user #{@user.name} (#{@user.id})", "to", @group)
        redirect_to group_path(@group.id)
      end  
    end
    
    def remove_member
      @group = services.identity.find_group(params[:group_id]) 
      enforce_permissions("identity:group_remove_member",{group: @group})
      services.identity.remove_group_member(@group.id,params[:id])
      audit_logger.info(current_user, "has removed user #{params[:id]}", "from", @group)
      redirect_to group_path(@group.id)
    end

    def new
      enforce_permissions("identity:group_create",{domain_id: @scoped_domain_id})
      @group = Identity::Group.new(nil,{})
    end
    
    def create
      enforce_permissions("identity:group_create",{domain_id: @scoped_domain_id})
      @group = services.identity.new_group(params[:group].merge(domain_id: @scoped_domain_id))
      if @group.save
        audit_logger.info(current_user, "has created", @group)
        redirect_to groups_path
      else
        render action: :new
      end
    end
    
    def edit
      @group = services.identity.find_group(params[:id])
      enforce_permissions("identity:group_update",{group: @group})
    end
    
    def update
      @group = services.identity.find_group(params[:id])
      enforce_permissions("identity:group_update",{group: @group})
      @group.description = params[:group][:description]
      if @group.save
        audit_logger.info(current_user, "has updated", @group)
        redirect_to group_path(@group.id)
      else
        render action: :edit
      end
    end
    
    def destroy
      @group = services.identity.find_group(params[:id])
      enforce_permissions("identity:group_delete",{group: @group})
      if @group.destroy
        audit_logger.info(current_user, "has deleted", @group)
        flash.now[:error] = @group.errors.full_messages.to_sentence
      end
      redirect_to groups_path
    end
    
  end
end
