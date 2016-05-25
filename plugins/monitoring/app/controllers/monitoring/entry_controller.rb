module Monitoring
  class EntryController < Monitoring::ApplicationController

    authorization_required

    def index

      if current_user.is_allowed?('monitoring:overview_list')
        redirect_to plugin('monitoring').overview_path
      else
        render action: 'howtoenable'
      end

    end

  end
end
