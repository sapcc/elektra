require 'ostruct'

module Automation
  class NodesController < ::Automation::ApplicationController
    authorization_context 'automation'
    authorization_required

    before_action :search_options, only: %i[index index_update]
    before_action :nodes_with_jobs, only: %i[index index_update]
    before_action :automations, only: %i[index index_update]

    def index
      if request.xhr?
        if params[:polling_service]
          # polling
          render partial: 'table_nodes', locals: { nodes: @nodes, jobs: @jobs }, layout: false
        elsif params[:search_service]
          # search
          params.delete(:search_service) # remove param to not be rendered in the pagination links
          render partial: 'table_nodes_pagination', layout: false
        end
      end

      # plain index page
    end

    def show
      node_id = params[:id]
      @node = services.automation.node(node_id, ['all'])
      @node_form = ::Automation::Forms::NodeTags.new(@node.attributes_to_form)
      @node_form_read = ::Automation::Forms::NodeTags.new(@node.attributes_to_form)
      @facts = @node.automation_facts
      @jobs = services.automation.jobs(node_id, 1, 100)
    end

    def install
      @compute_instances = services.compute.servers
    rescue StandardError => exception
      logger.error exception.message
      @compute_instances = []
      @errors = [{ key: 'danger', message: I18n.t('automation.errors.node_install_compute_unavailable') }]
    end

    def show_instructions
      @instance_id = instance_info[:id]
      @instance_type = instance_info[:type]
      @instance_os = params[:instance_os]
      @os_types = ::Automation::Node.os_types

      result = InstallNodeService.new.process_request(@instance_id, @instance_type, @instance_os, services.compute, services.automation)

      @instance = result[:instance]
      @login_info = result[:log_info]
      @script = result[:script]
      @messages = result[:messages]
    rescue InstallNodeParamError => exception
      @messages = exception.options[:messages]
      @errors = [{ key: 'warning', message: exception.message }]
    rescue InstallNodeInstanceOSNotFound => exception
      @messages = exception.options[:messages]
      @instance = exception.options[:instance]
      if params[:from] == 'select_os'
        return @errors = [{ key: 'warning', message: exception.message }]
      end
    rescue InstallNodeError => exception
      @messages = exception.options[:messages]
      @errors = [{ key: 'danger', message: exception.message }]
    rescue StandardError => exception
      @messages = if exception.respond_to?(:options)
                    exception.options[:messages]
                  else
                    ['error' => exception.message]
                  end
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      @errors = [{ key: 'danger', message: I18n.t('automation.errors.node_install_show_instructions_error') }]
    end

    # update node tags
    def update
      @node_form = ::Automation::Forms::NodeTags.new(params.to_unsafe_hash['forms_node_tags'])
      @error = false

      # validate and update
      if @node_form.update(services.automation)
        flash.now[:success] = I18n.t('automation.messages.node_updated_succesfully')
      else
        @error = true
      end

      # get the updated node tags data
      @node = services.automation.node(@node_form.agent_id, ['all'])
      @node_form_read = ::Automation::Forms::NodeTags.new(@node.attributes_to_form)
    rescue StandardError => exception
      Rails.logger.error exception.message
      flash.now[:error] = I18n.t('automation.errors.node_update_error')

      # get the original node tags
      @node = services.automation.node(@node_form.agent_id, ['all'])
      @node_form_read = ::Automation::Forms::NodeTags.new(@node.attributes_to_form)
    end

    def run_automation
      node_id = params[:node_id]
      automation_id = params[:automation_id]
      automation_name = params[:automation_name]
      # check if the node is online
      node = services.automation.node(node_id, ['all'])
      facts = node.automation_facts
      unless facts.attributes[:online]
        flash.now[:warning] = I18n.t('automation.errors.node_executing_automation_error_offline', name: automation_name)
        return
      end
      # run the automation
      run = services.automation.automation_execute(automation_id, "@identity='#{node_id}'")
      if run.save
        flash.now[:keep_success_htmlsafe] = "<b>#{automation_name}</b> successfully executed. See all runs on the Automations tab. #{view_context.link_to('Show details for this run.', plugin('automation').run_path(id: run.id), data: { modal: true }).html_safe}"
      else
        flash.now[:error] = I18n.t('automation.errors.node_executing_automation_error', name: automation_name, errors: run.errors)
      end
    rescue StandardError => exception
      logger.error "Automation-plugin: run_automation: #{exception.message}"
      flash.now[:error] = I18n.t('automation.errors.node_executing_automation_error', name: automation_name)
    end

    def destroy
      node_id = params[:id]
      node = begin
        services.automation.node(node_id, ['all'])
      rescue StandardError => exception
        Rails.logger.error exception.message
        nil
      end
      name = node.nil? ? node_id : node.name
      services.automation.node_delete(node_id)
      flash[:success] = "Node #{name} removed successfully."
      redirect_to plugin('automation').nodes_path
    end

    private

    def instance_info
      if params[:instance_type].nil?
        if params[:compute_instance_id] != 'external'
          { id: params[:compute_instance_id], type: 'compute' }
        else
          { id: params[:external_instance_id], type: 'external' }
        end
      else
        { id: params[:instance_id], type: params[:instance_type] }
      end
    end

    def search_options
      search_text = params[:search]
      search_query = SearchNodesService.search_query(search_text)
      if !search_text.nil? && search_query != params[:filter]
        params[:page] = 1
        # name tag, hostname or id
        params[:filter] = search_query
      end
    end

    def automations
      @automations = services.automation.automations_collect_all
    end

    def nodes_with_jobs
      # set defaults
      @node_page = params[:page] || 1
      @filter = params[:filter] || ''
      @search = params[:search] || ''
      per_page = 10

      service = IndexNodesService.new(services.automation)
      result = service.list_nodes_with_jobs(@node_page, per_page, @filter)

      @nodes = Kaminari.paginate_array(result[:elements], total_count: result[:total_elements]).page(@node_page).per(per_page)
      @jobs = result[:jobs]
    end
  end
end
