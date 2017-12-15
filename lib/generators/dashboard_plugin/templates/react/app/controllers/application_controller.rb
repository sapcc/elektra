# frozen_string_literal: true

module %{PLUGIN_NAME_CAMELIZE}
  class ApplicationController < DashboardController
    def show
      render inline: '<div id="%{PLUGIN_NAME}_react_container"/>', layout: true
    end
  end
end
