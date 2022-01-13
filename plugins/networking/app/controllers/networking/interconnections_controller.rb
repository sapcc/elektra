# frozen_string_literal: true

module Networking
  # Implements Network actions
  class InterconnectionsController < AjaxController

    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[index create destroy]

    def index
      code, interconnections = services.networking.interconnections()

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if code.to_i >= 400
        render json: {errors: interconnections}, status: code
      else
        render json: interconnections
      end 
    end

    def create
      code, interconnection = services.networking.create_interconnection(params.require(:name))

      if code.to_i >= 400
        render json: {errors: interconnection}, status: code
      else
        render json: interconnection
      end 
    end

    def destroy      
      code, interconnection = services.networking.delete_interconnection(params.require(:id))

      if code.to_i >= 400
        render json: {errors: interconnection}, status: code
      else
        head :ok
      end 
    end
  end
end
