# frozen_string_literal: true

module Lbaas
  STATE_UPDATE_INTERVAL = 15

  class ApplicationController < ::ScopeController
    def get_tags t
      tags = t.split(',')
      tags.each { |x| x.strip!() }
      return tags
    end
  end

end
