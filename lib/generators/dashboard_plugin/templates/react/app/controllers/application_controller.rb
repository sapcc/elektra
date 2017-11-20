# frozen_string_literal: true

module %{PLUGIN_NAME_CAMELIZE}
  class ApplicationController < DashboardController
    def show
      render inline: '', layout: true
    end
  end
end
