# frozen_String_literal: true

module EmailService
  class EmailsController < ::EmailService::ApplicationController
    before_action :email_form_attr, only: %i[new create]

    helper :all

    authorization_context 'email_service'
    authorization_required except: %i[]

    def index
      @emails = emails
    end

    def show
      @email = services.email_service.find_email(params[:id])
      # get the user name from the openstack id if available
      user = service_user.identity.find_user(@email.creator_id)
      @user = user ? user.name : @email.creator_id
    end

    def new; end

    def create
      @email = services.email_service.new_email(email_params)
      if @email.save
        redirect_to plugin('email_service').emails_path
      else
        render action: :new
      end
    end

    def destroy
      # delete email
      @email = services.email_service.new_email
      @email.id = params[:id]

      if @email.destroy
        flash.now[:success] = "email #{params[:id]} was successfully removed."
      end
      # grap a new list of secrets
      @emails = emails

      # render
      render action: :index
    end

    private

    def emails
      page = params[:page] || 1
      per_page = params[:limit] || 10
      offset = (page.to_i - 1) * per_page
      result = services.email_service.emails(
        sort: 'created:desc', limit: per_page, offset: offset
      )
      Kaminari.paginate_array(
        result[:items], total_count: result[:total]
      ).page(page).per(per_page)
    end

    def email_form_attr
      @email = services.email_service.new_email
    end

    def email_params
      unless params['email'].blank?
        email = params.clone.fetch('email', {})

        # remove if blank
        email.delete_if { |key, value| value.blank? }

        return email
      end
      return {}
    end
  end
end
