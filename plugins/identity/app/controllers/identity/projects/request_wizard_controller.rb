# frozen_string_literal: true

module Identity
  module Projects
    # This controller implemnts the workflow to create a project request
    class RequestWizardController < ::DashboardController
      before_action do
         enforce_permissions('identity:project_request',domain_id: @scoped_domain_id)
      end

      def new
        # get lobs and generate the list
        lob_list = ENV['LOB_LIST']
        lobs_and_board_area = lob_list.split(',') if lob_list
        lob_hash = {}
        lobs_and_board_area.each do |lob_and_ba |
          lob,ba = lob_and_ba.split('|')
          lob_hash[ba] ||= []
          lob_hash[ba] << lob
        end
        @lobs ||= []
        lob_hash.keys.sort.each do | board_area | 
          @lobs << [board_area, lob_hash[board_area].sort]
        end 

        @project = services.identity.new_project
        @project.enabled = true
        @project.parent_id = @scoped_project_id
        @project.parent_name = @scoped_project_name
        @project.cost_control = {}
        return unless services.available?(:cost_control)

        @cost_control_masterdata = services.cost_control.new_project_masterdata
      end

      def create
        @project = services.identity.new_project
        @project.attributes = params.fetch(:project, {})
                                    .merge(domain_id: @scoped_domain_id)
        # #{plugin('identity').domain_url(host: request.host_with_port, protocol: request.protocol)}?overlay=#{plugin('identity').domains_create_project_path(project_id: nil)}
        if @project.valid?
          begin
            inquiry = services.inquiry.create_inquiry(
              'project',
              "#{@project.name} - #{@project.description}",
              current_user,
              @project.attributes.to_json,
              service_user.identity.list_scope_resource_admins(
                domain_id: @scoped_domain_id
              ),
              {
                'approved': {
                  'name': 'Approve',
                  'action': ""
                }
              },
              nil, # no domain override
              { domain_name: @scoped_domain_name, region: current_region }
            )
            if inquiry.errors?
              render action: :new
            else
              flash.now[:notice] = 'Project request successfully created'
              audit_logger.info(current_user, "has requested project #{@project.attributes}")
              render template: 'identity/projects/request_wizard/create.js'
            end
          rescue StandardError => e
            @project.errors.add('message', e.message)
            render action: :new
          end
        else
          render action: :new
        end
      end
    end

    def edit
      payload = @inquiry.payload
      @project = Identity::Project.new(nil, {})
      if services.available?(:cost_control)
        @cost_control_masterdata = services.cost_control
                                           .new_project_masterdata(
                                             payload.delete(:cost_control)
                                           )
      end
      @project.attributes = payload
    end

    def update
      # user is not allowed to create a project (maybe)
      # so use admin identity for that!
      @project = Identity::Project.new(nil, {})
      @project.attributes = params.fetch(:project, {})
                                  .merge(domain_id: @scoped_domain_id)
      if @project.valid?
        inquiry = services.inquiry.change_inquiry(
          id: @inquiry.id,
          description: @project.description,
          payload: @project.attributes.to_json
        )
        if inquiry.errors?
          render action: :edit
        else
          render template: 'identity/projects/request_wizard/create.js'
        end
      else
        render action: :edit
      end
    end

    def load_and_authorize_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

      if @inquiry
        unless current_user.is_allowed?('identity:project_request',
                                        domain_id: @scoped_domain_id)
          render template: '/dashboard/not_authorized'
        end
      else
        render template: '/identity/projects/create_wizard/not_found'
      end
    end
  end
end
