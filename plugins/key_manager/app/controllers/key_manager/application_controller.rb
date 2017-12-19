# frozen_string_literal: true

module KeyManager
  # application controller
  class ApplicationController < ::DashboardController

     private

     def release_state
       'experimental'
     end
  end
end
