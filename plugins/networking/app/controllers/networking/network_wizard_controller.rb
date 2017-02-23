module Networking
  class NetworkWizardController < DashboardController
    before_filter :find_floatingip_network, :load_rbacs

    def new
      @network_wizard = Networking::NetworkWizard.new(nil,{
        setup_options: ["advanced"],
        setup_option: 'advanced'
      })

      if @floatingip_network
        @network_wizard.floatingip_network_name = @floatingip_network.name

        if @rbacs and @rbacs.length>0
          @network_wizard.setup_options = ["simple"]
          @network_wizard.setup_option = "simple"
        end
      else
        @network_wizard.errors.add(:floatingip_network, "Could not fine FloatingIP-Network")
      end
    end

    def create
      @network_wizard = Networking::NetworkWizard.new(nil,params[:network_wizard])

      if @floatingip_network
        @network_wizard.floatingip_network_name = @floatingip_network.name

        if @rbacs.nil? or @rbacs.length==0
          cloaud_admin_networking = service_user.cloud_admin_service(:networking)

          rbac = cloaud_admin_networking.new_rbac
          rbac.object_id     = @floatingip_network.id
          rbac.object_type   = 'network'
          rbac.action        = 'access_as_shared'
          rbac.target_tenant = @scoped_project_id

          unless rbac.save
            rbac.errors.each{|name,message| @network_wizard.errors.add(name,message)}
          end
          #byebug
        end
        #services.identity.grant_project_user_role_by_role_name(@project.id, current_user.id, 'network_admin')
        if @network_wizard.setup_option=='simple'

        end
      else
        @network_wizard.errors.add(:floatingip_network, "Could not fine FloatingIP-Network")
      end


      if @network_wizard.errors.empty?
        render action: :create
      else
        render action: :new
      end
    end

    protected
    def cloaud_admin_networking
      @cloaud_admin_networking ||= service_user.cloud_admin_service(:networking)
    end

    def find_floatingip_network
      @floatingip_network = cloaud_admin_networking.domain_floatingip_network(@scoped_domain_name)
    end

    def load_rbacs
      if @floatingip_network
        @rbacs = cloaud_admin_networking.rbacs({
          object_id: @floatingip_network.id,
          object_type: 'network',
          target_tenant: @scoped_project_id
        })
      end
    end
  end
end
