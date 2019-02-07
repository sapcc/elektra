# frozen_string_literal: true
module Inquiry
  # Implements Requests
  class InquiriesController < DashboardController
    authorization_context 'inquiry'
    authorization_required

    before_action :set_inquiry, only: %i[show edit update destroy]

    def index
      @domain_id = current_user.is_allowed?('cloud_admin') ? nil : current_user.user_domain_id
      # This is true if an update is made via the PollingService
      if params[:partial]
        filter = params[:filter] ? params[:filter] : {}
        @page = params[:page] || 1
        @inquiries = ::Inquiry::Inquiry.filter(filter).order(created_at: :desc).page(@page).per(params[:per_page])
        respond_to do |format|
          format.html {
            render partial: 'inquiries', locals: {inquiries: @inquiries, remote_links: true}, layout: false
          }
          format.js
        end
      elsif params[:csv]
        filter = params[:filter] ? params[:filter] : {}
        @inquiries = ::Inquiry::Inquiry.filter(filter).order(created_at: :desc)
        respond_to do |format|
          format.csv {
            send_data @inquiries.to_csv,
            filename: "inquiries-#{Date.today}.csv"
        }
        end
      else
        # This case is the initial page load

        # get all different types of inquiries from the database
        @kinds_of_inquiries = [['All','']] + ::Inquiry::Inquiry.pluck(:kind).uniq.sort

        render action: :index
      end
    end

    def new
      @inquiry = Inquiry.new(requester_id: current_user.id)
    end

    def show
    end

    def create
      # not really needed because inquiries are always created from somewhere else (projects, ....)
      # get the admins
      @inquiry = Inquiry.new
      admins = service_user.identity.list_scope_admins(
        domain_id: current_user.domain_id, project_id: current_user.project_id
      )

      @inquiry.kind = inquiry_params[:kind]
      @inquiry.description = inquiry_params[:description]
      @inquiry.domain_id = current_user.domain_id || current_user.project_domain_id
      @inquiry.project_id = current_user.project_id
      @inquiry.requester = Processor.from_users([current_user]).first
      @inquiry.processors = Processor.from_users(admins)
      @inquiry.payload = payload
      @inquiry.callbacks = callbacks

      if @inquiry.save
        flash.now[:notice] = 'Request successfully created.'
        redirect_to inquiries_path
      else
        flash.now[:error] = "Error creating request: #{inquiry.errors.full_messages.to_sentence}."
        Rails.logger.error "Inquiry(Request): Error creating inquiry: #{inquiry.errors.full_messages}"
        render action: :new
      end
    end


    def edit
      @inquiry.aasm_state = params[:state] if params[:state]
    end

    def update
      #@inquiry.change_state(inquiry_params[:aasm_state].to_sym, inquiry_params[:process_step_description], current_user)
      result = @inquiry.change_state(inquiry_params[:aasm_state].to_sym, inquiry_params[:process_step_description], current_user)
      if result
        flash.now[:notice] = "Request successfully updated."
        render 'inquiry/inquiries/update.js'
      else
        @inquiry.aasm_state = inquiry_params[:aasm_state]
        render action: :edit
      end
    end

    def destroy
      if @inquiry.destroy
        @inquiry = nil
        flash[:notice] = "Request successfully deleted."
        render template: 'inquiry/inquiries/update.js'
      else
        flash.now[:error] = @inquiry.errors.full_messages.to_sentence
        redirect_to :inquiries
      end
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:kind, :description, :aasm_state, :new_state, :process_step_description)
    end

    def set_inquiry
      @inquiry = ::Inquiry::Inquiry.find(params[:id])
    end


    # Todo: Only for testing purpose

    def callbacks
      return {
          "approved": {
              "name": "Create",
              "action": "project/compute/instances/new"
          },
          "rejected": {
              "name": "RejectedAction",
              "action": "rejected"
          }
      }
    end

    def payload
      return {
          "name": "the name",
          "description": "test",
          "enabled": "true",
          "domain_id": "abc123",
          "id": null
      }
    end
  end
end
