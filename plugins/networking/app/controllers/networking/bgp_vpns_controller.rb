# frozen_string_literal: true

module Networking
  # Implements Network actions
  class BgpVpnsController < AjaxController

    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[index]

    def index
      code, bgp_vpns = services.networking.bgp_vpns()

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if code.to_i >= 400
        render json: {errors: e.messages}, status: code
      else
        render json: bgp_vpns
      end 
    end
  end
end
