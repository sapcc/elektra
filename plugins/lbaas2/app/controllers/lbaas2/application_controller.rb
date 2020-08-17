# frozen_string_literal: true

module Lbaas2
  class ApplicationController < ::DashboardController
    def lbaas2_widget
    end

    def release_state
      'beta'
    end

  end
end
