# frozen_string_literal: true

require "spec_helper"

describe AccessProfile::ApplicationController, type: :controller do
  routes { AccessProfile::Engine.routes }
end
