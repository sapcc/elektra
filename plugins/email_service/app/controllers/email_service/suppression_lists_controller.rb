# frozen_string_literal: true

module EmailService
  # SuppressionListController
  class SuppressionListsController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus

    authorization_context 'email_service'
    authorization_required

    def index
      @suppressed_destinations = suppression_destination_list

      items_per_page = 250
      unless @suppressed_destinations.nil?
        @paginatable_suppressed_destinations =
          Kaminari
          .paginate_array(@suppressed_destinations, total_count: @suppressed_destinations.count)
          .page(params[:page])
          .per(items_per_page)
      end
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[
        :error
      ] = "#{I18n.t('email_service.errors.suppression_list_error')} #{e.message}"
    end

    # TODO: placeholder for further development
    def new; end
    def create; end
    def update; end
    def destroy; end

    def show
      @suppressed_destination = find_suppressed_destination(params[:email_address])
      render 'show', locals: { data: { modal: true }, item: @suppressed_destination }
    rescue Elektron::Errors::ApiResponse, StandardError => e
      flash.now[
        :error
      ] = "#{I18n.t('email_service.errors.template_show_error')} #{e.message}"
    end

    private

    def suppressed_destination_params
      if params.include?(:suppressed_destination)
        params.require(:suppressed_destination).permit(
          :id,
          :email_address,
          :last_update_time,
          :reason
        )
      else
        {}
      end
    end
  end
end
