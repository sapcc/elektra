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
        service_user.users(domain_id: @scoped_domain_id,name:params[:user_name]).first 
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
        redirect_to group_path(@group.id)
      end  
    end
    
    def remove_member
      @group = services.identity.find_group(params[:group_id]) 
      enforce_permissions("identity:group_remove_member",{group: @group})
      services.identity.remove_group_member(@group.id,params[:id])
      redirect_to group_path(@group.id)
    end

    def new
      enforce_permissions("identity:group_create",{domain_id: @scoped_domain_id})
    end
    
    def create
      enforce_permissions("identity:group_create",{domain_id: @scoped_domain_id})
    end
    
    def edit
      enforce_permissions("identity:group_update",{domain_id: @scoped_domain_id})
    end
    
    def update
      enforce_permissions("identity:group_update",{domain_id: @scoped_domain_id})
    end
    
    def destroy
      enforce_permissions("identity:group_delete",{domain_id: @scoped_domain_id})
    end
    
  end
end
