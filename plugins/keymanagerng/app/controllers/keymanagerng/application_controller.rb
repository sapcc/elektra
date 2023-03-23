# frozen_string_literal: true

module Keymanagerng
  class ApplicationController < AjaxController
    def user_name
      # byebug
      render json:
               cloud_admin
                 .identity
                 .find_user(params.require(:user_id))
                 .try(:name)
    rescue Exception => e
      puts e.inspect
      render json: { errors: e.message }, status: "500"
    end
  end
end
