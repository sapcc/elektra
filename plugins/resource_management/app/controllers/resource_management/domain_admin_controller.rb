require_dependency "resource_management/application_controller"

module ResourceManagement
  class DomainAdminController < ::ResourceManagement::ApplicationController
    before_action :load_project_resource, only: %i[edit cancel update]
    before_action :load_domain_resource,
                  only: %i[
                    new_request
                    create_request
                    reduce_quota
                    confirm_reduce_quota
                    cancel
                    update
                  ]
    before_action :load_inquiry, only: %i[review_request approve_request]
    before_action :load_package_inquiry,
                  only: %i[review_package_request approve_package_request]

    authorization_required

    def index
      @domain = services.resource_management.find_domain(@scoped_domain_id)
      @view_services = @domain.services

      # find resources to show
      @critical_resources =
        @domain.resources.reject do |res|
          res.backend_quota.nil? and not res.infinite_backend_quota? and
            res.quota >= res.projects_quota
        end

      @index = true
      @areas = @domain.services.map(&:area).uniq
    end

    def show_area(area = nil)
      @area = area || params.require(:area).to_sym

      # which services belong to this area?
      @domain = services.resource_management.find_domain(@scoped_domain_id)
      @view_services =
        @domain.services.select { |srv| srv.area.to_sym == @area }
      if @view_services.empty?
        raise ActiveRecord::RecordNotFound, "unknown area #{@area}"
      end

      @areas = @domain.services.map(&:area).uniq
    end

    def edit
      # please do not delete
    end

    def cancel
      respond_to { |format| format.js { render action: "update" } }
    end

    def update
      @domain_resource = @resource # XXX cleanup

      old_quota = @project_resource.quota
      begin
        new_quota = @project_resource.data_type.parse(params.require(:value))
      rescue ArgumentError => e
        render plain: e.message, status: :bad_request
        return
      end

      # check if new quota fits within domain quota (TODO: this should be done by Limes)
      old_projects_quota = @domain_resource.projects_quota
      new_projects_quota = old_projects_quota - old_quota + new_quota

      if new_quota < 0 or new_projects_quota > @domain_resource.quota
        max_value = @domain_resource.quota - old_projects_quota + old_quota
        msg =
          "Domain quota for #{@project_resource.service_type}/#{@project_resource.name} exceeded (maximum acceptable project quota is #{@project_resource.data_type.format(max_value)})"
        render plain: msg, status: :bad_request
        return
      end

      # set quota
      @project_resource.quota = new_quota
      unless @project_resource.save
        render plain: @project_resource.errors.full_messages.to_sentence,
               status: :bad_request
        return
      end

      # make sure that row is not rendered with red background color
      @project_resource.backend_quota = nil
      # make sure that usage bars are rendered with correct quota sum
      @domain_resource.projects_quota += new_quota - old_quota

      respond_to { |format| format.js }
    end

    def confirm_reduce_quota
      # please do not delete
    end

    def reduce_quota
      old_quota = @resource.quota
      value = params[:new_style_resource][:quota]
      if value.empty?
        @resource.add_validation_error(:quota, "is missing")
      else
        begin
          value = @resource.data_type.parse(value)

          # NOTE: there are additional validations in the NewStyleResource class
          if @resource.quota < value
            @resource.add_validation_error(
              :quota,
              "is higher than current quota",
            )
          else
            @resource.quota = value
          end
        rescue ArgumentError => e
          @resource.add_validation_error(:quota, "is invalid: " + e.message)
        end
      end

      # save the new quota to database
      if @resource.save
        show_area(@resource.service_area)
      else
        # reload the reduce quota window with error
        @resource.quota = old_quota
        respond_to do |format|
          format.html { render action: "confirm_reduce_quota" }
        end
      end
    end

    def review_request
      @desired_quota = @inquiry.payload["desired_quota"]
      @maximum_quota =
        @domain_resource.quota - @domain_resource.projects_quota +
          @project_resource.quota

      @project_name = services.identity.find_project(@inquiry.project_id).name

      # calculate projected domain status after approval
      @domain_resource_projected = @domain_resource.clone
      @domain_resource_projected.projects_quota +=
        @desired_quota - @project_resource.quota
    end

    def approve_request
      old_quota = @project_resource.quota
      begin
        @desired_quota =
          @project_resource.data_type.parse(
            params.require(:new_style_resource).require(:quota),
          )
      rescue => e
        @project_resource.add_validation_error(
          :quota,
          "is invalid: " + e.message,
        )
      end

      # check that domain quota is not exceeded
      @maximum_quota =
        @domain_resource.quota - @domain_resource.projects_quota +
          @project_resource.quota
      if @desired_quota and @desired_quota > @maximum_quota
        max_quota_str = @project_resource.data_type.format(@maximum_quota)
        @project_resource.add_validation_error(
          :quota,
          "is too large (would exceed total domain quota), maximum acceptable project quota is #{max_quota_str}",
        )
      end

      @project_resource.quota = @desired_quota

      if @project_resource.save
        comment =
          "New project quota is #{@project_resource.data_type.format(@project_resource.quota)}"
        if params[:new_style_resource][:comment].present?
          comment +=
            ", comment from approver: #{params[:new_style_resource][:comment]}"
        end
        services.inquiry.set_inquiry_state(
          @inquiry.id,
          :approved,
          comment,
          current_user,
        )
      else
        @project_resource.quota = old_quota # reset quota to render view correctly
        self.review_request
        render action: "review_request"
      end
    end

    def review_package_request
      @project =
        services.resource_management.find_project(
          @scoped_domain_id,
          @inquiry.project_id,
        )
      @domain = services.resource_management.find_domain(@scoped_domain_id)

      @target_project_name =
        services.identity.find_project(@inquiry.project_id).name

      # check if request fits into domain quotas
      @can_approve = true
      # show only those resources in the review screen where the approval of
      # the request would increase the current_quota allocated to the project
      @relevant_resources = []
      @domain.resources.each do |domain_resource|
        project_resource =
          @project.find_resource(
            domain_resource.service_type,
            domain_resource.name,
          )
        next if project_resource.nil?

        package_quota =
          @package.quota(domain_resource.service_type, domain_resource.name)
        new_projects_quota =
          domain_resource.projects_quota - project_resource.quota +
            package_quota
        if new_projects_quota > domain_resource.projects_quota and
             new_projects_quota > domain_resource.quota
          @can_approve = false
        end

        if package_quota > project_resource.quota
          @relevant_resources.append(domain_resource)
        end
      end
    end

    def approve_package_request
      # apply quotas from package to project, but take existing approved quotas into account
      @project =
        services.resource_management.find_project(
          @scoped_domain_id,
          @inquiry.project_id,
        )
      @project.resources.each do |res|
        new_quota = @package.quota(res.service_type, res.name)
        res.quota = [res.quota, new_quota].max
      end

      if @project.save
        @services_with_error = @project.services_with_error
        services.inquiry.set_inquiry_state(
          @inquiry.id,
          :approved,
          "Approved",
          current_user,
        )
        render action: "approve_request"
      else
        @errors = @project.errors
        review_package_request
        render action: "review_package_request"
      end
    end

    def new_request
      # please do not delete
    end

    def create_request
      old_value = @resource.quota
      data_type = @resource.data_type
      new_value = params.require(:new_style_resource).require(:quota)

      # parse and validate value
      begin
        new_value = data_type.parse(new_value)
        @resource.quota = new_value
        if new_value <= old_value ||
             data_type.format(new_value) == data_type.format(old_value)
          # the second condition catches slightly larger values that round to the same representation, e.g. 100.000001 GiB
          @resource.add_validation_error(
            :quota,
            "must be larger than current value",
          )
        end
      rescue ArgumentError => e
        @resource.add_validation_error(:quota, "is invalid: " + e.message)
      end
      # back to square one if validation failed
      unless @resource.validate
        render action: :new_request
        return
      end

      # create inquiry
      base_url =
        plugin("resource_management").cloud_admin_area_path(
          area: @resource.service_area.to_s,
          domain_id: Rails.configuration.cloud_admin_domain,
          project_id: Rails.configuration.cloud_admin_project,
        )
      overlay_url =
        plugin("resource_management").cloud_admin_review_request_path(
          domain_id: Rails.configuration.cloud_admin_domain,
          project_id: Rails.configuration.cloud_admin_project,
        )

      cloud_admin_domain =
        cloud_admin
          .identity
          .domains(name: Rails.configuration.cloud_admin_domain)
          .first
      cloud_admin_domain_id =
        (
          if cloud_admin_domain.blank?
            Rails.configuration.cloud_admin_domain
          else
            cloud_admin_domain.id
          end
        )
      inquiry =
        services.inquiry.create_inquiry(
          "domain_quota",
          "domain #{@scoped_domain_name}: add #{@resource.data_type.format(new_value - old_value)} #{@resource.service_type}/#{@resource.name}",
          current_user,
          {
            service: @resource.service_type,
            resource: @resource.name,
            desired_quota: new_value,
          },
          cloud_admin.identity.list_cloud_resource_admins,
          {
            approved: {
              name: "Approve",
              action: "#{base_url}?overlay=#{overlay_url}",
            },
          },
          nil, #requester domain id
          { domain_name: @scoped_domain_name, region: current_region },
          cloud_admin_domain_id, #approver domain id
        )
      if inquiry.errors?
        render action: :new_request
        return
      end

      respond_to { |format| format.js }
    end

    def details
      @sort_order = params[:sort_order] || "asc"
      @sort_column = params[:sort_column] || ""
      sort_by = @sort_column.gsub("_column", "")

      @service_type = params.require(:service).to_sym
      @resource_name = params.require(:resource).to_sym

      domain =
        services.resource_management.find_domain(
          @scoped_domain_id,
          service: @service_type.to_s,
          resource: @resource_name.to_s,
        )
      @domain_resource = domain.resources.first or
        raise ActiveRecord::RecordNotFound, "no such domain"
      projects =
        services.resource_management.list_projects(
          @scoped_domain_id,
          service: @service_type.to_s,
          resource: @resource_name.to_s,
        )
      @project_resources = projects.map { |p| p.resources.first }.reject(&:nil?)

      # show danger and warning projects on top if no sort by is given
      if sort_by.empty?
        ## prepare the projects table
        @project_resources =
          @project_resources.sort_by do |res|
            # warn about projects with mismatching frontend<->backend quota
            sort_order = res.backend_quota.nil? ? 1 : 0
            # sort projects by warning level, then by name
            [sort_order, (res.project_name || res.project_id).downcase]
          end
      else
        sort_method = sort_by.to_sym
        @project_resources.sort_by! do |r|
          [r.send(sort_method), r.sortable_name]
        end
        @project_resources.reverse! if @sort_order.downcase == "desc"
      end

      @project_resources =
        Kaminari.paginate_array(@project_resources).page(params[:page]).per(6)

      respond_to do |format|
        format.html
        format.js
      end
    end

    private

    def load_project_resource
      project =
        services.resource_management.find_project(
          @scoped_domain_id,
          params.require(:id),
          service: [params.require(:service)],
          resource: [params.require(:resource)],
        ) or
        raise ActiveRecord::RecordNotFound,
              "project #{params[:project]} not found"
      @project_resource = project.resources.first or
        raise ActiveRecord::RecordNotFound, "resource not found"
    end

    def load_domain_resource
      enforce_permissions(":resource_management:domain_admin_list")
      @resource =
        services
          .resource_management
          .find_domain(
            @scoped_domain_id,
            service: Array.wrap(params.require(:service)),
            resource: Array.wrap(params.require(:resource)),
          )
          .resources
          .first or raise ActiveRecord::RecordNotFound
    end

    def load_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
      # Error Handling
      unless @inquiry
        render html: "Could not find inquiry!"
        return
      end

      enforce_permissions(
        "resource_management:admin_approve_request",
        { inquiry: { requester_uid: @inquiry.requester.uid } },
      )

      # load additional data
      data = @inquiry.payload.symbolize_keys
      if data.include?(:resource_id)
        raise ArgumentError,
              "inquiry #{@inquiry.id} has not been migrated to new format!"
      end

      @project_resource =
        services
          .resource_management
          .find_project(
            @scoped_domain_id,
            @inquiry.project_id,
            service: [data[:service]],
            resource: [data[:resource]],
          )
          .resources
          .first or raise ActiveRecord::RecordNotFound

      @domain_resource =
        services
          .resource_management
          .find_domain(
            @scoped_domain_id,
            service: [data[:service]],
            resource: [data[:resource]],
          )
          .resources
          .first or raise ActiveRecord::RecordNotFound
    end

    def load_package_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
      # Error Handling
      unless @inquiry
        render html: "Could not find inquiry!"
        return
      end

      enforce_permissions(
        "resource_management:admin_approve_package_request",
        { inquiry: { requester_uid: @inquiry.requester.uid } },
      )

      # load additional data
      @package =
        ResourceManagement::Package.find(
          @inquiry.payload.symbolize_keys[:package],
        )
    end
  end
end
