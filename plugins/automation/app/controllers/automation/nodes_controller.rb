require 'ostruct'

module Automation

  class NodesController < ::Automation::ApplicationController
    before_action :nodes_with_jobs, only: [:index, :index_update]
    before_action :automations, only: [:index, :index_update]

    def index
    end

    def index_update
      render partial: 'table_nodes', locals: {nodes: @nodes, jobs: @jobs, addresses: @addresses, external_nodes: @external_nodes}, layout: false
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
      begin
        @compute_instances = services.compute.servers
      rescue => exception
        logger.error exception.message
        @compute_instances = []
        @errors = [{key: "danger", message: I18n.t('automation.errors.node_install_compute_unavailable')}]
      end
    end

    def show_instructions
      @instance_id = instance_info[:id]
      @instance_type = instance_info[:type]
      @instance_os = params[:instance_os]
      @os_types = ::Automation::Node.os_types

      result = InstallNodeService.new().process_request(@instance_id, @instance_type, @instance_os, services.compute, services.automation)

      @instance = result[:instance]
      @login_info = result[:log_info]
      @script = result[:script]
      @messages = result[:messages]

    rescue InstallNodeParamError => exception
      @messages = exception.options[:messages]
      return @errors = [{key: "warning", message: exception.message}]
    rescue InstallNodeInstanceOSNotFound => exception
      @messages = exception.options[:messages]
      @instance = exception.options[:instance]
      if params[:from] == 'select_os'
        return @errors = [{key: "warning", message: exception.message}]
      end
    rescue InstallNodeError => exception
      @messages = exception.options[:messages]
      return @errors = [{key: "danger", message: exception.message}]
    rescue => exception
      if exception.respond_to?(:options)
        @messages = exception.options[:messages]
      else
        @messages = ['error' => exception.message]
      end
      logger.error "Automation-plugin: show_instructions: #{exception.message}"
      return @errors = [{key: "danger", message: I18n.t('automation.errors.node_install_show_instructions_error')}]
    end

    def update
      @node_form = ::Automation::Forms::NodeTags.new(params['forms_node_tags'])
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
    rescue => exception
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
      run = services.automation.automation_execute(automation_id,"@identity='#{node_id}'")
      if run.save
        flash.now[:success] = "Automation #{automation_name} was successfully executed. Click following #{view_context.link_to('link', plugin('automation').run_path(id: run.id), data: {modal: true}).html_safe} to see the details."
      else
        flash.now[:error] = I18n.t('automation.errors.node_executing_automation_error', name: automation_name, errors: run.errors)
      end
    rescue => exception
      logger.error "Automation-plugin: run_automation: #{exception.message}"
      flash.now[:error] = I18n.t('automation.errors.node_executing_automation_error', name: automation_name)
    end

    def destroy
      node_id = params[:id]
      node = begin
        services.automation.node(node_id, ['all'])
      rescue => exception
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
      unless params[:instance_type].nil?
        return {id: params[:instance_id], type: params[:instance_type]}
      else
        if params[:compute_instance_id] != 'external'
          return {id: params[:compute_instance_id], type: 'compute'}
        else
          return {id: params[:external_instance_id], type: 'external'}
        end
      end
    end

    def automations
      @automations = services.automation.automations
    end

    def nodes_with_jobs
      page = params[:page]||1
      per_page = 5
      service = IndexNodesService.new(services.automation, services.compute)
      result = service.list_nodes_with_jobs(page, per_page)

      @nodes = Kaminari.paginate_array(result[:elements], total_count: result[:total_elements]).page(page).per(per_page)
      @jobs = result[:jobs]
      @addresses = result[:addresses]
      @external_nodes = result[:external_nodes]
    end

  end

end
